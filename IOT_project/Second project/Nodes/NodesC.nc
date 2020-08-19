//********* This is the Sensor node which acquires data and send it to the Root ***********


#include <Timer.h>
#include "nodes.h"
#include <printf.h>

module NodesC {

	uses interface Boot;
	uses interface Timer<TMilli> as Data_timer;
	uses interface Timer<TMilli> as Retransmission_timer;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
	uses interface Random;


}

implementation {

	bool busy = FALSE;
	message_t pkt;
	uint16_t ackpktid;
	uint16_t nodeidin;
	uint16_t tonodein;
	uint16_t pktidin;
	uint16_t pcktid = 1;
	uint16_t Timer_Value;
	uint16_t usagerand;
	uint16_t temprand;
	uint16_t inusage;
	uint16_t intemp;
	uint16_t pastpktid;
	

//********* Booting the devices ***********
	//It boots the device
	event void Boot.booted() {
		//It starts the radio
		call AMControl.start();
		//Here for each node we start a random timer value so when this fires it sends a sampled data
		Timer_Value = (call Random.rand16()%5000)+15000;
		//A random data called usagerand is generated
		usagerand = call Random.rand16()%100;
		//A random data called temprand is generated
		temprand = call Random.rand16()%45;
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			//If the radio is successfully turned on we start the timer for sending the data
			call Data_timer.startPeriodic(Timer_Value);
		}
		else {
			//If radio didn't turn on successfully we try to start it again
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

//********* Timer fired, creating, and sending the message ***********
	
	event void Data_timer.fired() {
				//Here we feel the message payload
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				//First we set the ID of this node as the Sender address of our protocol
				ndpkt -> nodeid = TOS_NODE_ID;
				//We set the ID of the root node as the Destination address of our protocol
				ndpkt -> tonode = 8;
				//We give our message an ID for the purpose of acknowledgement and uniqueness of each message sent
				ndpkt -> pckid = pcktid;
				//We put our datas in the payload of the message
				ndpkt -> usage = usagerand;
				ndpkt -> temp = temprand;
				//If the radio layer (Active message layer) accepts our packet with success we set our radio in use flag to busy
				if (!busy && call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;
					//Here we start the retransmission time-out timer for 1 second
					call Retransmission_timer.startPeriodic(1000);
					//Here we stop the main timer to stop sending a new data if acquired
					call Data_timer.stop();
					//We put the ID of the packet that must be ACKed in ackpktid variable for later comparison purposes
					ackpktid = pcktid;
			}
	}
	//This is the retransmission timer when it fires the packet is sent again
	event void Retransmission_timer.fired() {
				//Here a packet exactly the same as the above packet is created for retransmission
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt -> nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid;
				ndpkt -> usage = usagerand;
				ndpkt -> temp = temprand;
				if (!busy && call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;	
			}
	}

//********* Receiving the message ***********

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {	
			//If the length of message is as we expected
			if (len == sizeof(NodesInMsg)) {
				//We fisrt get the payload of the received message and then get the Destionation address of the packet and put it in tonodein variable
				NodesInMsg* ndinpkt = (NodesInMsg*)payload;
				tonodein = ndinpkt -> tonodein;
				//If the Destination address is the same as this node's ID (address) we accept the packet and start processing it
				if (tonodein == TOS_NODE_ID) {
					//We get the message packet ID out to check for retransmission
					pktidin = ndinpkt -> pktidin;
					//We get the Source address of the packet out and put it in nodeidin variable
					nodeidin = ndinpkt -> nodeidin;
					//We get the usage data in the packet payload out these are 0 since they come from the root node but they can be used to send back data
					inusage = ndinpkt -> usagein;
					//We get the temp data in the packet payload out
					intemp = ndinpkt -> tempin;
					//We check if this message is unique and not a duplicate by checking the packet ID against a past received packet ID
					if (pktidin != pastpktid) {
						//We update the pastpktid variable
						pastpktid = pktidin;
						//printf("Acked packet id: %u\n", ackpktid);	//Uncomment to see the ACKed packet ID that is received
						//We check if packet ID of this recevied packet is the same as the sent packet (The ID of the sent packet was assigned to ackpktid variable)
						if (pktidin == ackpktid) {
							//If this packet was ACKed correctly we stop the retransmission timer and turn on the data timer
							call Retransmission_timer.stop();
							call Data_timer.startPeriodic(Timer_Value);
							//We increment the packet ID
							pcktid++;
							//Here we acquire two new data values
							usagerand = call Random.rand16()%100;
							temprand = call Random.rand16()%45;
						}
					}
				}
			}
				return msg;
	}

//********* Sending the packet ***********
	//If the packet is send correctly sendDone signals success
	event void AMSend.sendDone(message_t* msg, error_t error) {
		//If the msg is the same as buffer we set the busy flag to FALSE to release the radio resuorce
		if (&pkt == msg) {
    		busy = FALSE;
    	}
	}

}
