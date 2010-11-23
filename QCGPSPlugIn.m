//
//  QCGPSPlugIn.m
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

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>
#import "QCGPSPlugIn.h"

#define	kQCPlugIn_Name				@"GPS"
#define	kQCPlugIn_Description		@"The patch acts as a client to GPSd.  It relays positioning information from the server into Quartz for use by patches."

@implementation QCGPSPlugIn

/*
Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputFoo, outputBar;
*/

@dynamic outputLatitude, outputLongitude, outputAltitude, outputHasFix, outputConnectedToGpsd, inputServerName, inputServerPort, outputSpeed, outputDirection, outputSatellites, outputHDOP;

+ (NSDictionary*) attributes
{
	/*
	Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	*/
	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/*
	Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	*/
	
	if ([key isEqualToString:@"inputServerName"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Server Address", QCPortAttributeNameKey,
				@"localhost", QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputServerPort"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Server Port", QCPortAttributeNameKey,
				@"2947", QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"outputLatitude"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Latitude", QCPortAttributeNameKey,
				nil];
	
	if ([key isEqualToString:@"outputLongitude"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Longitude", QCPortAttributeNameKey,
				nil];
	
	if ([key isEqualToString:@"outputAltitude"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Altitude", QCPortAttributeNameKey,
				nil];
	
	if ([key isEqualToString:@"outputHasFix"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Has Fix", QCPortAttributeNameKey,
				nil];
	
	if ([key isEqualToString:@"outputConnectedToGpsd"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Connected to GPSd", QCPortAttributeNameKey,
				nil];
	
	if ([key isEqualToString:@"outputSpeed"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Speed (km/h)", QCPortAttributeNameKey,
				nil];
	
	if ([key isEqualToString:@"outputDirection"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Direction (deg)", QCPortAttributeNameKey,
				nil];
	
	if ([key isEqualToString:@"outputSatellites"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Satellites", QCPortAttributeNameKey,
				nil];
	
	if ([key isEqualToString:@"outputHDOP"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"HDOP", QCPortAttributeNameKey,
				nil];
	
	
	
	return nil;
}

+ (QCPlugInExecutionMode) executionMode
{
	/*
	Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	*/
	
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	/*
	Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	*/
	
	return kQCPlugInTimeModeIdle;
}

- (id) init
{
	if(self = [super init]) {
		/*
		Allocate any permanent resource required by the plug-in.
		*/
		
	}
	
	return self;
}

- (void) finalize
{
	/*
	Release any non garbage collected resources created in -init.
	*/
	
	
	[super finalize];
}

- (void) dealloc
{
	/*
	Release any resources created in -init.
	*/
	
	[super dealloc];
}

@end

@implementation QCGPSPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/

	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/
	struct sockaddr_in serv_name;
	
	// connect to the server.
	iGPSdSocket = socket(AF_INET, SOCK_STREAM, 0);
	if (iGPSdSocket == -1) {
		// failure creating socket
		NSLog(@"Socket creation failure!");
		return;
	}
	const char* hostname = "localhost";// [self.inputServerName UTF8String];
	
	UInt32 ip = inet_addr(hostname);
	if (ip == INADDR_NONE) {
		// not an IP. look it up
		struct hostent *hp;
		hp = gethostbyname(hostname);
		if (hp == NULL) {
			// couldn't lookup hostname
			NSLog(@"Failed to resolve host name: %s", hostname);
			return;
		}
		
		ip = *(int *)hp->h_addr_list[0];
	}
	
	// we have the ip address
	// create the socket
	serv_name.sin_addr.s_addr = ip;
	serv_name.sin_family = AF_INET;
	serv_name.sin_port = htons(2947);//(short)[self.inputServerPort intValue]);
	
	//NSLog(@"Connecting to GPSd at (%s:%s)", inet_ntoa(serv_name.sin_addr), self.inputServerPort);
	
	int status = connect(iGPSdSocket, (struct sockaddr*)&serv_name, sizeof(serv_name));
	
	if (status == -1) {
		NSLog(@"Connection refused?");
		return;
	}
	
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
	
	char gpsbuf[MAX_GPSBUF_LEN];
	
	if (write(iGPSdSocket, "PMVTAQ\r\n", 8) < 8) {
		NSLog(@"GPSd write failed");
		return NO;
	}
	
	int len;
	if ((len = read(iGPSdSocket, &gpsbuf[0], MAX_GPSBUF_LEN)) < 0) {
		NSLog(@"GPSd read failed");
		return NO;
	}
	
	int valid;
	double ns, ew, elev, velkt, veldir, numsat, shdop;
	if (sscanf(gpsbuf, "GPSD,P=%lg %lg,M=%d,V=%lg,T=%lg,A=%lg,Q=%lg %*lg %lg",
			   &ns, &ew, &valid, &velkt, &veldir, &elev, &numsat, &shdop) >= 4) {
		self.outputHasFix = valid >= 2;
		self.outputLatitude = ns;
		self.outputLongitude = ew;
		self.outputAltitude = elev;
		self.outputSpeed = velkt * KNOTS_TO_KMH_CONVERSION;
		self.outputDirection = veldir;
		self.outputSatellites = numsat;
		self.outputHDOP = shdop;
		
	} else {
		// failure parsing
		NSLog(@"Failure parsing gpsd data.");
		return NO;
	}
	
	self.outputConnectedToGpsd = true;
	
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/
	close(iGPSdSocket);
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/
}

@end
