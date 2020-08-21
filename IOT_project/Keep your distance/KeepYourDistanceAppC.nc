#include <Timer.h>
#include "KeepYourDistance.h"
#include "StorageVolumes.h"

configuration KeepYourDistanceAppC {
}
implementation {
	components MainC;
	components LedsC;
	components KeepYourDistanceC as App;
	components new TimerMilliC() as Timer;
	components new TimerMilliC() as Read_timer;
	components new TimerMilliC() as Rate_limiter;
	components ActiveMessageC;
	components new AMSenderC(AM_KEEPYOURDISTANCE);
	components new AMReceiverC(AM_KEEPYOURDISTANCE);
	components new LogStorageC(VOLUME_IDLOG, TRUE);
	components PrintfC;
	components SerialStartC;
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> Timer;
	App.Read_timer -> Read_timer;
	App.Rate_limiter -> Rate_limiter;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
	App.LogRead -> LogStorageC;
	App.LogWrite -> LogStorageC;

}
