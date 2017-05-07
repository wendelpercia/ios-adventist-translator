//
//  MUListChannelController.m
//  Adventist_Translator
//
//  Created by Wendel O Percia on 07/05/17.
//
//

#import "MUListChannelController.h"

#import "MUTranslatorChannel.h"
#import "MUServerViewController.h"
#import "MUConnectionController.h"

#include <ifaddrs.h>
#include <arpa/inet.h>


@implementation MUListChannelController

+ (NSMutableArray *) fetchAllChannels {
    
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    
    MUConnectionController *connCtrlr = [MUConnectionController sharedController];
    
    [connCtrlr connetToHostname:@"192.168.1.78"
                           port:64738
                   withUsername:@"Teste-2"
                    andPassword:@""
       withParentViewController:nil];
    
    MUListChannelController *mUListChannelController = [[MUListChannelController alloc] init];
    NSString *myIP = [mUListChannelController getIPAddress];
    
    //NSString *myIPTeste = @"Wendel";
    
    NSLog(@"%@", myIP);
    
    
    MUTranslatorChannel *res = [[MUTranslatorChannel alloc] init];
    
    [res setPrimaryKey: -1];
    [res setDisplayName: NSLocalizedString(@"en", nil)];
    [channels addObject:res];
    [res release];

    res = [[MUTranslatorChannel alloc] init];
    [res setPrimaryKey: 0];
    [res setDisplayName: NSLocalizedString(@"es", nil)];
    [channels addObject:res];

    res = [[MUTranslatorChannel alloc] init];
    [res setPrimaryKey: 1];
    [res setDisplayName: NSLocalizedString(@"pt-BR", nil)];
    [channels addObject:res];

    res = [[MUTranslatorChannel alloc] init];
    [res setPrimaryKey: 2];
    [res setDisplayName: NSLocalizedString(@"fr", nil)];
    [channels addObject:res];
    
    
    return [channels autorelease];
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end
