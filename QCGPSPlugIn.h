//
//  QCGPSPlugIn.h
//  QCGPS
//
//  Created by Michael Farrell on 2010-11-17.
//  Copyright (c) 2010 Michael Farrell. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import <Quartz/Quartz.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#define MAX_GPSBUF_LEN 1024
// knots * X = kmh
#define KNOTS_TO_KMH_CONVERSION 1.852

@interface QCGPSPlugIn : QCPlugIn
{
	@protected
	int iGPSdSocket;
}

/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@property(assign) NSString* inputServerName;
@property(assign) NSString* inputServerPort;

@property double outputLatitude;
@property double outputLongitude;
@property double outputAltitude;
@property double outputSpeed;
@property double outputDirection;
@property double outputSatellites;
@property double outputHDOP;
@property BOOL outputHasFix;
@property BOOL outputConnectedToGpsd;

@end
