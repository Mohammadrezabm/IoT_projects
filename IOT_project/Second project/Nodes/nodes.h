#ifndef NODES_H
#define NODES_H

enum {
	AM_NODES = 6,
};

typedef nx_struct NodesMsg {
	nx_uint16_t nodeid;
	nx_uint16_t tonode;
	nx_uint16_t pckid;
	nx_uint16_t data;

} NodesMsg;

typedef nx_struct NodesInMsg {
	nx_uint16_t nodeidin;
	nx_uint16_t tonodein;
	nx_uint16_t pktidin;
	nx_uint16_t datain;

} NodesInMsg;

#endif
