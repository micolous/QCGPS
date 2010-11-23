//
//  QCGPSPlugIn.h
//  QCGPS
//
//  Created by Michael Farrell on 2010-11-17.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

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
