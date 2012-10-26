#include "broadcast-base.h"
#include "random.h"

//
// bind C++ to TCL
//
int hdr_broadcastbase::offset_;

static class BroadcastbaseHeaderClass : public PacketHeaderClass {
 public:
  BroadcastbaseHeaderClass() : PacketHeaderClass("PacketHeader/Broadcastbase", sizeof(hdr_broadcastbase)) {
    bind_offset(&(hdr_broadcastbase::offset_));
  }
} class_broadcastbasehdr;

static class BroadcastbaseClass : public TclClass {
 public:
  BroadcastbaseClass() : TclClass("Agent/Broadcastbase"){}
  TclObject* create(int, const char*const*) {
    return (new BroadcastbaseAgent() );
  }
} class_broadbastbase;
// end of binding

// When snd_timer_ expires call BroadcastbaseAgent:sendit()
void SendTimer::expire(Event*)
{
  t_->sendit();
}

// Constructor (also initialize instances of timers)
BroadcastbaseAgent::BroadcastbaseAgent() : Agent(PT_BROADCASTBASE),snd_timer_(this)
{
  bind("packetSize_", &size_);
  //bind("off_broadcastbase_", &off_broadcastbase_);
}  

// OTcl command interpreter
int BroadcastbaseAgent::command(int argc, const char*const* argv)
{
  if (argc == 3) {
    if (strcmp(argv[1], "set-ll")==0) {
         if( (obj = TclObject::lookup(argv[2])) == 0) {
        	fprintf(stderr, " Broadcastbase(set-ll): %s lookup of %s failed \n", argv[1],argv[2]);
           return(TCL_ERROR);
         }
      ll = (NsObject *) obj;
      return (TCL_OK);
    }
  }
  if (argc == 2) {
    if (strcmp(argv[1], "send")==0) {
      sendit();
      return (TCL_OK);
    }
  }
  return (Agent::command(argc, argv));
}

void BroadcastbaseAgent::sendit()
{
  Packet *p = Packet::alloc();
  struct hdr_cmn *ch = HDR_CMN(p);
  struct hdr_ip *ih = HDR_IP(p);
 
  ch->ptype() = PT_BROADCASTBASE;
  ch->next_hop_ = IP_BROADCAST;

  ih->saddr() = Agent::addr();
  ih->daddr() = IP_BROADCAST;
  ih->sport() = RT_PORT;
  ih->dport() = RT_PORT;
  ih->ttl_ = 1;
 
  Scheduler::instance().schedule(ll,p,0.0); 
 
  // Reschedule the send_pkt timer
  double next_time_ = next_snd_time();
  if(next_time_ > 0) snd_timer_.resched(next_time_);
}

// Schedule next data packet transmission time
double BroadcastbaseAgent::next_snd_time()
{    
  double next_time_ = 5;  
  next_time_ += 5 * Random::uniform(-0.5, 0.5);
  return next_time_;
}