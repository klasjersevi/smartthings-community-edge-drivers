-- Copyright 2022 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local cc = require "st.zwave.CommandClass"
local capabilities = require "st.capabilities"
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version = 1 })
local Battery = (require "st.zwave.CommandClass.Battery")({ version = 1 })
local SensorBinary = (require "st.zwave.CommandClass.SensorBinary")({ version = 2 })
local SensorMultilevel = (require "st.zwave.CommandClass.SensorMultilevel")({ version = 5 })
local Notification = (require "st.zwave.CommandClass.Notification")({ version = 3 })
local WakeUp = (require "st.zwave.CommandClass.WakeUp")({version = 2})
local utils = require "st.utils"
local log = require "log"

local PHILIO_DOOR_SENSOR = {
  { manufacturerId = 0x013C, productType = 0x0002, productId = 0x000C }
}

local TAMPER_INIT_DELAY = 5 * 60
local TAMPER_CLEAR_DELAY = 24 * 60 * 60
local REPORT_PREFERENCE_NUM = 9

local function can_handle_philio_door_sensor(opts, driver, device, ...)
  for _, fingerprint in ipairs(PHILIO_DOOR_SENSOR) do
    if device:id_match(fingerprint.manufacturerId, fingerprint.productType, fingerprint.productId) then
      return true
    end
  end
  return false
end

local function deactivateTamper(device)
  device:emit_event(capabilities.tamperAlert.tamper.clear())
end

local function device_added(driver, device)
  -- device:emit_event(capabilities.motionSensor.motion.inactive())
  device:send(Battery:Get({}))
  device:send(SensorBinary:Get({ sensor_type = SensorBinary.sensor_type.DOOR_WINDOW }))
  device:send(SensorBinary:Get({ sensor_type = SensorBinary.sensor_type.MOTION }))
  device:send(SensorMultilevel:Get({ sensor_type = SensorMultilevel.sensor_type.LUMINANCE}))
  device:send(SensorMultilevel:Get({ sensor_type = SensorMultilevel.sensor_type.TEMPERATURE}))
  -- device:refresh()

  device.thread:call_with_delay(
    TAMPER_CLEAR_DELAY,
    function(d)
      deactivateTamper(device)
    end
  )
end

local function wakeup_notification(driver, device, cmd)
  if cmd.args.sensor_type == SensorBinary.sensor_type.DOOR_WINDOW then
    device:send(SensorBinary:Get({ sensor_type = SensorBinary.sensor_type.DOOR_WINDOW }))
  elseif cmd.args.sensor_type == SensorBinary.sensor_type.MOTION then
    device:send(SensorBinary:Get({ sensor_type = SensorBinary.sensor_type.MOTION }))
  elseif cmd.args.sensor_type == SensorMultilevel.sensor_type.LUMINANCE then
    device:send(SensorMultilevel:Get({ sensor_type = SensorMultilevel.sensor_type.LUMINANCE}))
  elseif cmd.args.sensor_type == SensorMultilevel.sensor_type.TEMPERATURE then
    device:send(SensorMultilevel:Get({ sensor_type = SensorMultilevel.sensor_type.TEMPERATURE}))
  else
    device:send(Battery:Get({}))
    device:send(Configuration:Get({parameter_number = REPORT_PREFERENCE_NUM}))
  end
end

local function activateTamper(device)
  device:emit_event(capabilities.tamperAlert.tamper.detected())
  device.thread:call_with_delay(
    TAMPER_CLEAR_DELAY,
    function(d)
      deactivateTamper(device)
    end
  )
end

local function get_lux_from_percentage(percentage_value)
  local conversion_table = {
    {min = 1, max = 9.99, multiplier = 3.843},
    {min = 10, max = 19.99, multiplier = 5.231},
    {min = 20, max = 29.99, multiplier = 4.999},
    {min = 30, max = 39.99, multiplier = 4.981},
    {min = 40, max = 49.99, multiplier = 5.194},
    {min = 50, max = 59.99, multiplier = 6.016},
    {min = 60, max = 69.99, multiplier = 4.852},
    {min = 70, max = 79.99, multiplier = 4.836},
    {min = 80, max = 89.99, multiplier = 4.613},
    {min = 90, max = 100, multiplier = 4.5}
  }
  for _, tables in ipairs(conversion_table) do
    if percentage_value >= tables.min and percentage_value <= tables.max then
      return utils.round(percentage_value * tables.multiplier)
    end
  end
  return utils.round(percentage_value * 5.312)
end

local function sensor_multilevel_report_handler(self, device, cmd)
  if cmd.args.sensor_type == SensorMultilevel.sensor_type.LUMINANCE then
    device:emit_event(capabilities.illuminanceMeasurement.illuminance({value = get_lux_from_percentage(cmd.args.sensor_value), unit = "lux"}))
  elseif cmd.args.sensor_type == SensorMultilevel.sensor_type.TEMPERATURE then
    local scale = cmd.args.scale == SensorMultilevel.scale.temperature.FAHRENHEIT and 'F' or 'C'
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = cmd.args.sensor_value, unit = scale}))
  end
end

local function deactivateTamper(device)
  device:emit_event(capabilities.tamperAlert.tamper.clear())
end

local function activateTamper(device)
  device:emit_event(capabilities.tamperAlert.tamper.detected())
  device.thread:call_with_delay(
    TAMPER_CLEAR_DELAY,
    function(d)
      deactivateTamper(device)
    end
  )
end

local function notification_handler(driver, device, cmd)
  local notification_type = cmd.args.notification_type
  local notification_event = cmd.args.event

  if (notification_type == Notification.notification_type.HOME_SECURITY) then
    if notification_event == Notification.event.home_security.TAMPERING_PRODUCT_COVER_REMOVED then
      activateTamper(device)
    elseif notification_event == Notification.event.home_security.STATE_IDLE then
      deactivateTamper(device)
    end
  end
end


local philio_door_sensor = {
  NAME = "Philio PST02 Sensor",
  lifecycle_handlers = {
    added = device_added
  },
  zwave_handlers = {
    [cc.SENSOR_MULTILEVEL] = {
      [SensorMultilevel.REPORT] = sensor_multilevel_report_handler
    },
    [cc.WAKE_UP] = {
      [WakeUp.NOTIFICATION] = wakeup_notification
    },
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    },
  },
  can_handle = can_handle_philio_door_sensor
}

return philio_door_sensor
