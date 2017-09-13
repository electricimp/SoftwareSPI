// MIT License
//
// Copyright (c) 2017 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Big banging SPI class
class SoftwareSPI {

    static VERSION = "0.1.0";

    // Same as imp error messages
    static ERROR_BAD_PARAMS_WRITE     = "bad parameters to spi.write(data)";
    static ERROR_BAD_PARAMS_WRITEREAD = "bad parameters to spi.writeread(data)";

    // SCLK, MOSI, MISO pin variables
    _sclk  = null;
    _mosi = null;
    _miso = null;

    constructor(sclk, mosi, miso) {
        _sclk = sclk;
        _mosi = mosi;
        _miso = miso;
        
        // Configure pins
        _sclk.configure(DIGITAL_OUT, 0);
        _mosi.configure(DIGITAL_OUT, 0);
        _miso.configure(DIGITAL_IN);
    }
    
    function write(data) {
        //Local variables to speed things up
        local cw = _sclk.write.bindenv(_sclk);
        local dw = _mosi.write.bindenv(_mosi);
        local mask;

        if (typeof data == "string") {
            local b = blob(data.len());
            data = b.writestring(data);
        }

        if (typeof data != "blob") throw ERROR_BAD_PARAMS_WRITE;

        foreach (byte in data) {
            for (mask = 0x80; mask > 0; mask = mask >> 1) {
                cw(0);
                dw(byte & mask);
                imp.sleep(0.000001);
                cw(1);
                imp.sleep(0.000001);
            }
        }

        cw(0);
        return data.len();
    }
    
    function writeread(data) {
        //Local variables to speed things up
        local cw = _sclk.write.bindenv(_sclk);
        local dw = _mosi.write.bindenv(_mosi);
        local dr = _miso.read.bindenv(_miso);
        local mask;

        local read_val = 0; 
        local data_len = data.len();
        local read_blob = blob(data_len);
        local rtnString = false;
        
        if (typeof data == "string") {
            rtnString = true;
            local b = blob(data_len);
            data = b.writestring(data);
        }

        if (typeof data != "blob") throw ERROR_BAD_PARAMS_WRITEREAD;

        foreach (byte in data) {
            for(mask = 0x80; mask > 0; mask = mask >> 1) {
                cw(0);
                dw(byte & mask);
                imp.sleep(0.000001);
                // read the last byte
                read_val = (read_val << 1) | (dr() ? 1 : 0);
                cw(1);
                imp.sleep(0.000001);
            }
            read_blob.writen(read_val, 'b');
            read_val = 0;
        }

        cw(0);
        
        if (rtnString) {
            return read_blob.tostring();
        } else {    
            return read_blob;
        }
    }
    
    function readstring (numChars) {
        return readblob(numChars).tostring();
    }

    function readblob(numChars){
        // Local variables to speed things up
        local cw = _sclk.write.bindenv(_sclk);
        local dr = _miso.read.bindenv(_miso);
        local mask;

        local read_blob = blob(numChars);

        for (local a = 0; a < numChars; a++) {
            local byte = 0;
            for (local b = 0; b < 8; b++) {
                cw(0);
                imp.sleep(0.000001);
                byte = (byte << 1) | (dr() ? 1 : 0);
                cw(1);
                imp.sleep(0.000001);
            }
            read_blob.writen(byte, 'b');
        }

        cw(0);

        read_blob.seek(0, 'b');
        return read_blob;
    }
}
