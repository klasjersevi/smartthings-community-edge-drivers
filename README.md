# Smartthings Community Edge Drivers

This is a repo for unofficial community created edge drivers for Smartthings. These drivers are mainly based on the official drivers found at [SmartThingsCommunity](https://github.com/SmartThingsCommunity)/[SmartThingsEdgeDrivers](https://github.com/SmartThingsCommunity/SmartThingsEdgeDrivers). All drivers are meant to be compatible with the official repo. If you are a manufacturer, feel free to submit official drivers based on these drivers.

All drivers are provided *as is*. **Use these drivers on your own risk!**

Any contributions are welcome!

# Channel invitation

You can install or uninstall these drivers directly from the web to your Smartthings hub by accepting the channel invitation.

> [Driver Channel Invitation](https://bestow-regional.api.smartthings.com/invite/r3My4NRWvzjp)

# Z-Wave drivers

## Siterwell Smoke Alarm Sensor (GS559B)

Z-Wave+ smoke alarm with optical smoke sensor and heat alarm.

### Also branded as

 - Nexa Smoke Detector (ZSD-109)

### References

 - https://products.z-wavealliance.org/products/2599

 - https://community.openhab.org/t/solved-adding-new-device-on-opensmarthouse/144769

---

 ## Philio Slim Multisensor (PST02-A/B/C)

 Z-Wave+ multisensor available in three variants; A, B and C.
 
 *Note:* only the 4-in-1 (A) sensor is currently tested.

 ### Variants

- PST02-1A 4-in-1 multisensor. Door/window, PIR, temperature, light

- **Untested** PST02-1B 3-in-1 multisensor. PIR, temperature, light.

- **Untested** PST02-1C 3-in-1 multisensor. Door/window, temperature, light.

### References
- https://products.z-wavealliance.org/products/1087/
- https://products.z-wavealliance.org/products/1449/
- https://manual.zwave.eu/backend/make.php?lang=en&sku=PHI_PST02-1A
- https://manual.zwave.eu/backend/make.php?lang=en&sku=PHI_PST02-1B
- https://manual.zwave.eu/backend/make.php?lang=en&sku=PHI_PST02-1C
- https://www.zwavetaiwan.com.tw/pst02
- https://github.com/ertanden/SmartThingsPublic/blob/master/devicetypes/ertanden/philio-pst02-1a.src/philio-pst02-1a.groovy
- https://github.com/Roysteroonie/Hubitat/blob/master/Hubitat%20-%20Philio%20PST02-1A%20Sensor.groovy