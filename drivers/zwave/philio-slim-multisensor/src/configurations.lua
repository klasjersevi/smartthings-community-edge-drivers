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

--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version=4 })
--- @type st.zwave.CommandClass.Association
local Association = (require "st.zwave.CommandClass.Association")({ version=2 })
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({ version=3 })
--- @type st.zwave.CommandClass.WakeUp
local WakeUp = (require "st.zwave.CommandClass.WakeUp")({ version = 2 })

local devices = {
  PHILIO_DOOR_SENSOR = {
    MATCHING_MATRIX = {
      mfrs = 0x013C,
      product_types = 0x0002,
      product_ids = 0x000C
    },
    CONFIGURATION = {
      -- PIR Sensitivity 1-100
      {parameter_number = 3, configuration_value = 80, size = 1},
      -- Light threshold
      {parameter_number = 4, configuration_value = 50, size = 1},
      -- Operation mode
      {parameter_number = 5, configuration_value = 0, size = 1},
      --  Multi-Sensor Function Switch
      {parameter_number = 6, configuration_value = 4, size = 1},
      -- Customer Function
      {parameter_number = 7, configuration_value = 54, size = 1},
      -- PIR re-detect interval time
      {parameter_number = 8, configuration_value = 3, size = 1},
      -- Turn Off Light Time
      {parameter_number = 9, configuration_value = 4, size = 1},
      -- Auto report Battery time 1-127, default 12
      {parameter_number = 10, configuration_value = 120, size = 1},
      -- Auto report Door/Window state time 1-127, default 12
      {parameter_number = 11, configuration_value = 12, size = 1},
      -- Auto report Illumination time 1-127, default 12
      {parameter_number = 12, configuration_value = 12, size = 1},
      -- Auto report Temperature time 1-127, default 12
      {parameter_number = 13, configuration_value = 12, size = 1}
    }
  }
}
local configurations = {}

configurations.initial_configuration = function(driver, device)
  local configuration = configurations.get_device_configuration(device)
  if configuration ~= nil then
    for _, value in ipairs(configuration) do
      device:send(Configuration:Set(value))
    end
  end
  local association = configurations.get_device_association(device)
  if association ~= nil then
    for _, value in ipairs(association) do
      local _node_ids = value.node_ids or {driver.environment_info.hub_zwave_id}
      device:send(Association:Set({grouping_identifier = value.grouping_identifier, node_ids = _node_ids}))
    end
  end
  local notification = configurations.get_device_notification(device)
  if notification ~= nil then
    for _, value in ipairs(notification) do
      device:send(Notification:Set(value))
    end
  end
  local wake_up = configurations.get_device_wake_up(device)
  if wake_up ~= nil then
    for _, value in ipairs(wake_up) do
      local _node_id = value.node_id or driver.environment_info.hub_zwave_id
      device:send(WakeUp:IntervalSet({seconds = value.seconds, node_id = _node_id}))
    end
  end
end

configurations.get_device_configuration = function(zw_device)
  for _, device in pairs(devices) do
    if zw_device:id_match(
      device.MATCHING_MATRIX.mfrs,
      device.MATCHING_MATRIX.product_types,
      device.MATCHING_MATRIX.product_ids) then
      return device.CONFIGURATION
    end
  end
  return nil
end

configurations.get_device_association = function(zw_device)
  for _, device in pairs(devices) do
    if zw_device:id_match(
      device.MATCHING_MATRIX.mfrs,
      device.MATCHING_MATRIX.product_types,
      device.MATCHING_MATRIX.product_ids) then
      return device.ASSOCIATION
    end
  end
  return nil
end

configurations.get_device_notification = function(zw_device)
  for _, device in pairs(devices) do
    if zw_device:id_match(
      device.MATCHING_MATRIX.mfrs,
      device.MATCHING_MATRIX.product_types,
      device.MATCHING_MATRIX.product_ids) then
      return device.NOTIFICATION
    end
  end
  return nil
end

configurations.get_device_wake_up = function(zw_device)
  for _, device in pairs(devices) do
    if zw_device:id_match(
      device.MATCHING_MATRIX.mfrs,
      device.MATCHING_MATRIX.product_types,
      device.MATCHING_MATRIX.product_ids) then
      return device.WAKE_UP
    end
  end
  return nil
end

return configurations
