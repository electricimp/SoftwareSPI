# Software SPI #

This library provides software-based bit-bang SPI (Serial Peripheral Interface) that can be used as an alternative to the imp API’s [**hardware.spi**](https://developer.electricimp.com/api/hardware/spi) object. This class contains the same read and write methods as the imp API.

**Note** The only supported SPI mode is currently 0 (CPOL 0, CPHA 0) with the most significant bit sent first. Clock speed cannot be configured when using this class. 

**To add this library to your project, add** `#require "SoftwareSPI.device.lib.nut:0.1.0"` **to the top of your device code**

## Class Usage ## 

### Constructor: SoftwareSpi(*sclk, mosi, miso*) ###

The constructor has three parameters, all of which are required: *sclk*, the serial clock signal; *mosi*, the data output; and *miso*, the data input. All parameters are imp **pin** objects that will be configured by the class. 

**Note** This class does not configure or toggle a chip-select pin. Your application should take care of this functionality. 

```squirrel
local sclk = hardware.pinA; // Clock
local mosi = hardware.pinB; // Master Output 
local miso = hardware.pinC; // Maste Input

local sspi = SoftwareSPI(sclk, mosi, miso);
```

## Class Methods ##

### write(*data*) ###

This method writes the specified data to the software SPI and returns the number of bytes written. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *data* | String or blob | Yes | The data to be sent via SPI |

#### Return Value ####

Integer &mdash; the number of bytes written.

#### Example ####

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Write data to a blob
local value = blob(4); 
value.writen(0xDEADBEEF, 'i');

// Write data to SPI
cs.write(0);
sspi.write(value);
cs.write(1);
```

### writeread(*data*) ###

This method writes to, and concurrently reads data from, the software SPI. The size and type of the data returned matches the size and type of the data sent.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *data* | String or blob | Yes | The data to be sent via SPI |

#### Return Value ####

String or blob &mdash; the data read from SPI.

#### Example ####

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Write and read data to/from SPI
cs.write(0);
local value = sspi.writeread("\xFF");
cs.write(1);

server.log(value);
```

### readstring(*numberOfBytes*) ###

This method reads the specified number of bytes from the software SPI and returns it as a string.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *numberOfBytes* | Integer | Yes | The number of bytes to be read from SPI |

#### Return Value ####

String &mdash; the data read from SPI.

#### Example ####

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Read 8 bytes of data from SPI and log it
cs.write(0);
local value = sspi.readstring(8);
cs.write(1);

server.log(value);
```

### readblob(*numberOfBytes*) ###

This method reads the specified number of bytes from the software SPI and returns it as a Squirrel blob.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *numberOfBytes* | Integer | Yes | The number of bytes to be read from SPI |

#### Return Value ####

Blob &mdash; the data read from SPI.

#### Example ####

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Read 2 bytes of data from SPI and log it
cs.write(0);
local value = spi.readblob(2);
cs.write(1);

server.log(value);
```

## License ##

The SoftwareSPI library is licensed under the [MIT License](./LICENSE).
