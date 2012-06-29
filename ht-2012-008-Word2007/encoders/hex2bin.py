#! /usr/bin/env python

#Copyright HT srl, 2009-2010
#http://www.hackingteam.it/ for more information

#cod

"""
hex 2 bin
Transform an input array in byte array (hex format: 00 bin firmat: \\0)

"""

VERSION = "1.0"

NAME="hex2bin"
DESCRIPTION="hex2bin converter"
DOCUMENTATION={}
DOCUMENTATION["VENDOR"] = "HT srl"
DOCUMENTATION["Repeatability"] = "not applicable"
DOCUMENTATION["Author"] = "cod"
DOCUMENTATION["Notes"] = ""

import os
import sys

class hex2bin:

	"""
	ctor
	"""

	def bin_value(self, b):
		return "0123456789abcdef".index(b.lower())
		
	def get(self, data):
		value = ""
		size = len(data)
		
		if (size % 2) != 0:
			raise ValueError("error in data length")

		i = 0
		while i < size:
			b0 = self.bin_value(data[i])
			b1 = self.bin_value(data[i+1])
			
			i += 2
			
			b0 = (b0 << 4) + b1
			value += chr(b0)

		return value
		
if __name__ == "__main__":
	print "hex2bin"
	
	print "Getting input file"
	
	myclass = hex2bin()
	
	print "Opening file ", sys.argv[1]
	
	fd = open(sys.argv[1], "rb")
	
	array = fd.read()
	
	outdata = myclass.get(array)
	
	#report
	print outdata
	
	print "Transform completed"
