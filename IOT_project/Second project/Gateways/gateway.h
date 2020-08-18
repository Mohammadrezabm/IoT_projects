#ifndef GATEWAY_H
#define GATEWAY_H

enum {
	AM_GATEWAY = 6,
	

};

typedef nx_struct GatewayMsg {
	nx_uint16_t nodeidgateway;
	nx_uint16_t tonodegateway;
	nx_uint16_t pktidgateway;
	nx_uint16_t datagateway;

} GatewayMsg;
typedef nx_struct GatewayOutMsg {
	nx_uint16_t nodeidgatewayout;
	nx_uint16_t tonodegatewayout;
	nx_uint16_t pktidgatewayout;
	nx_uint16_t datagatewayout;


} GatewayOutMsg;

#endif
