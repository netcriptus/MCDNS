#ifndef ns_broadcast_base_h
#define ns_broadcast_base_h

#include "agent.h"
#include "tclcl.h"
#include "packet.h"
#include "address.h"
#include "ip.h"
#include "timer-handler.h"

NsObject *ll;
TclObject *obj;

//Basestation broadcast beacon header structure
struct hdr_broadcastbase {
  nsaddr_t  src;  //Source IP Address
  
  // Packet header access functions
  static int offset_;
  //inline static int& offset() {return offset_; }
  inline static hdr_broadcastbase* access(const Packet* p) {
    return (hdr_broadcastbase*) p->access(offset_);
  }
};

class BroadcastbaseAgent;

// Sender uses this timer to 
// schedule next app data packet transmission time
class SendTimer : public TimerHandler {
 public:
        SendTimer(BroadcastbaseAgent* t) : TimerHandler(), t_(t) {}
        inline virtual void expire(Event*);
 protected:
        BroadcastbaseAgent* t_;
};

//Basestation broadcast beacon agent class
class BroadcastbaseAgent : public Agent {
 friend class SendTimer;
 public:
  BroadcastbaseAgent();
  int command(int argc, const char*const* argv);
  //protected:
  //int off_broadcastbase_;
 private:
  void sendit();
  inline double next_snd_time();
  
  SendTimer snd_timer_;  // SendTimer
};

#endif