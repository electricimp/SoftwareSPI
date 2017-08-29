# SoftwareSPI

This library contains a bit bang SPI class that can be used as an alternative to the Imp API SPI object. This class contains the same read and write methods as the imp API hardware SPI object. Please note that clock speed cannot be configured with this class. 

**To add this library to your project, add** #require "SoftwareSPI.device.lib.nut:0.1.0" **to the top of your device code**

## Class Usage

### Constructor: SoftwareSpi(*sclk, mosi, miso*)

The constructor takes three required parameters: *sclk*, the serial clock signal, *mosi*, data output, and *miso*, data input. All parameters are hardware pin ojects that will be configured by the class. 

**Note:** This class does not configure or toggle a chip select pin. Your application should take care of this functionality. 

```squirrel
local sclk = hardware.pinA; //clock
local mosi = hardware.pinB; //output 
local miso = hardware.pinC; //input

local spi = SoftwareSPI(sclk, mosi, miso);
```

## Class Methods

The methods below match the Imp API SPI read and write methods.

## write(*data*)

The *write()* method writes the specified data to the Software SPI and returns the number of bytes written. This method takes one required parameter *data*, a string or blob containing the data to be written.

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Write data to a blob
local value = blob(4); 
value.writen(0xDEADBEEF,'i');

// Write data to SPI
cs.write(0);
spi.write(value);
cs.write(1);
```

## writeread(*data*)

The *writeread()* method writes to, and concurrently reads data from the Software SPI. This method takes one required parameter *data*, a string or blob containing the data to be written. The size and type of the data returned matches the same as the size and type of the data sent.

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Write and read data to/from SPI
cs.write(0);
local value = spi.writeread("\xFF");
cs.write(1);

server.log(value);
```


## readstring(*numberOfBytes*)

The *readstring()* method reads a specified quantity of data from the Software SPI and returns it as a string. This method takes one required parameter *numberOfBytes*, an integer, how many bytes to read in from the bus.

```squirrel
// Configure chip select
local cs = hardware.pinD;
cs.configure(DIGITAL_OUT, 1);

// Read 8 bytes of data from SPI and log it
cs.write(0);
local value = spi.readstring(8);
cs.write(1);

server.log(value);
```

## readblob(*numberOfBytes*)

The *readblob()* method reads a specified quantity of data from the Software SPI and returns it as a Squirrel blob. This method takes one required parameter *numberOfBytes*, an integer, how many bytes to read in from the bus.

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
