#include <Timer.h>
#include "KeepYourDistance.h"
#include "printf.h"
#include "StorageVolumes.h"

module KeepYourDistanceC {

	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer;
	uses interface Timer<TMilli> as Read_timer;
	uses interface Timer<TMilli> as Rate_limiter;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
	uses interface LogRead;
	uses interface LogWrite;

}

implementation {

	bool busy = FALSE;
	bool m_busy = TRUE;
	message_t pkt;
	uint16_t violating_node;
	uint16_t violated_node = 0;  
	
	//Memory variable data types definition
	typedef nx_struct memory_t {
	nx_uint8_t saved_node_id;
	message_t msg;
	} memory_t;
  
	memory_t mem_addr;

//********* Booting the devices ***********
	
	event void Boot.booted() {
	
		//We start the radio
		call AMControl.start();
	}

//********* Turning the radio on and in case of success start the timer ***********

	event void AMControl.startDone(error_t err) {
	
		//If starting the radio was successful we start a timer
		if (err == SUCCESS) {
			call Timer.startPeriodic(TIMER_VALUE);
			
			//For log we don't need mounting so we just need to read some bytes
			if (call LogRead.read(&mem_addr, sizeof(memory_t)) != SUCCESS) {
			}
		}
		
		//If the radio did not turn on we try to turn it on again
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

//********* Memory read event *********
	
	//After memory read call this readDone will be signaled
	event void LogRead.readDone(void* buf, storage_len_t len, error_t err) {
	
		//If the length or the message returned is as we expected we read the memory and display the data
		if ( (len == sizeof(memory_t)) && (buf == &mem_addr) ) {
		
			//Turns off the green LED to show the end of reading proess
			call Leds.led1Off();
		
			//printf("Memory read successfully. Saved node ID is: %u\n", mem_addr.saved_node_id);	//Uncomment please to see the debug
		}
		
		//If the length or the memory data returned is not as we expected we earse the memory
		else {
		
			//This erases the memory
			if (call LogWrite.erase() != SUCCESS) {
      		}
      		
    	}
  	}
	
	//This is signaled when memory erase is called
	event void LogWrite.eraseDone(error_t err) {
    	if (err == SUCCESS) {
     		 m_busy = FALSE;
   		}
    	else {
    	}
  	}


//********* Timer fired, creating, and sending the message which contains the node ID ***********

	//Timer is fired every 500 milliseconds
	event void Timer.fired() {
	
		//If the radio is not busy we create the message by putting the node ID in it and send it
		if (!busy) {
		
			//Creating the message and filling it's payload with the node ID
			KeepYourDistanceMsg* sdpkt = (KeepYourDistanceMsg*)(call Packet.getPayload(&pkt, sizeof (KeepYourDistanceMsg)));
			sdpkt -> nodeid = TOS_NODE_ID;
			
			//If the returned error of send will be success we set the value of the radio to busy to reserve it this means the AM layer has accepted the packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(KeepYourDistanceMsg)) == SUCCESS) {
				busy = TRUE;
			}
		}
	}
	
	//This timer provides limiting functionality on the number of times the violating node ID is written in the memory to every 3 seconds
	event void Rate_limiter.fired() {
	
			//Turns off the alarm LED so it won't be left on in case of seperation of violating nodes
			call Leds.led0Off();
			
			//Sets the violating node ID to 0 so we can enter the if condition again if the nodes are not seperated
			violated_node = 0;

	}
	
	event void Read_timer.fired() {
	
		//After 3 seconds that two nodes are in proximity this function reads and displays the violating node ID on the screen
		call LogRead.read(&mem_addr, sizeof(memory_t));
		
		//Turns on the green LED to show the start of reading process
		call Leds.led1On();
	}
	
	//When the sendDone signals success it means the packet is sent correctly
	event void AMSend.sendDone(message_t* msg, error_t error) {
	
		//If the msg is the same as the buffer we set the busy flag to FALSE to release the radio resource
		if (&pkt == msg) {
			busy = FALSE;
		}
	}

//********* Receiving the message and triggering the alarm containing the violating node ID ***********

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
	
		//We check the length of the message to be the same as we expected
		if (len == sizeof(KeepYourDistanceMsg)) {
		
			//We get the payload and from it extract the ID of the violating node
			KeepYourDistanceMsg* sdpkt = (KeepYourDistanceMsg*)payload;
			
			//Assign the ID of violating node to violating_node variable
			violating_node = sdpkt -> nodeid;
			
			//Start switching ON and OFF the red LED of the node as an alarm
			call Leds.led0Toggle();
			
			//To prevent constant writting in the memory array we check if the ID of the violating node has changed or not
			if (violating_node != violated_node) {

				//If the memory is not busy we start assigning values to it
				if (!m_busy) {
				
					//Turns on the blue LED to show the start of writing process
					call Leds.led2On();
					
					//Setting the memory busy flag to TRUE
      				m_busy = TRUE;
      				
      				//Assigning the violatin node ID to the saved_node_ID of the memory
					mem_addr.saved_node_id = violating_node;
					
					//Assigning the whole message structure to the msg variable of the memory
					mem_addr.msg = *msg;
					
					//This calls writing on the memory
					if (call LogWrite.append(&mem_addr, sizeof(memory_t)) != SUCCESS) {
							m_busy = FALSE;
					  	}
				}

				//updates the violated node ID for comparison
				violated_node = violating_node;
				
				//calles the limiter timer for limiting the number of memory writings to 3 seconds
				call Rate_limiter.startOneShot(3000);
				
				//Calls a timer to read the memory 
				call Read_timer.startOneShot(4500);

			}
			
			//Prints the alarm and the ID of the violating node
			printf("Alarm! The violating mote is: %u\n", violating_node);
			
			//Cleans the screen of the node
			printfflush();
		}
		return msg;
	}
	
	//Logwrtie.append function signals this LogWrite.appendDone that returns all the information on the written data and if it signals no errors it means the data is written to memory successfully
	event void LogWrite.appendDone(void* buf, storage_len_t len, bool recordsLost, error_t err) {
	
		//Sets the memory busy falg to FALSE to free it for later use
    	m_busy = FALSE;
    	
    	//If the writting process was done successfully the blue LED turns off
    	call Leds.led2Off();
    	
    	//If the writting process was done successfully this message is shown on the screen
    	//printf("Memory write complete without errors!\n");	//Uncomment please to see the message
  	}

  	event void LogRead.seekDone(error_t err) {
  	}

  	event void LogWrite.syncDone(error_t err) {
  	}
  	
}
