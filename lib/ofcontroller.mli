(*
 * Copyright (c) 2011 Richard Mortier <mort@cantab.net>
 * Copyright (c) 2011 Charalampos Rotsos <cr409@cl.cam.ac.uk>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Net

module Event : sig
    open Ofpacket

    (** Event messages *)
    type t =
        DATAPATH_JOIN
      | DATAPATH_LEAVE
      | PACKET_IN
      | FLOW_REMOVED
      | FLOW_STATS_REPLY
      | AGGR_FLOW_STATS_REPLY
      | DESC_STATS_REPLY
      | PORT_STATS_REPLY
      | TABLE_STATS_REPLY
      | PORT_STATUS_CHANGE

    type e =
        Datapath_join of datapath_id * Ofpacket.Port.phy list
      | Datapath_leave of datapath_id
      | Packet_in of Port.t * Packet_in.reason * int32 * 
                      Cstruct.t * datapath_id
      | Flow_removed of Match.t * Flow_removed.reason * 
          int32 * int32 * int64 * int64 * datapath_id
      | Flow_stats_reply of int32 * bool * Flow.stats list * datapath_id
      | Aggr_flow_stats_reply of int32 * int64 * int64 * int32 * datapath_id
      | Port_stats_reply of int32 * bool * Port.stats list * datapath_id
      | Table_stats_reply of int32 * bool * Stats.table list * datapath_id
      | Desc_stats_reply of string * string * string * string * string * datapath_id
      | Port_status of Port.reason * Port.phy * datapath_id

      (** convert a controller event to a string representation *)
    val string_of_event : e -> string
  end

type t

(** [register_cb ctrl evt fn] registers a callback for a specific event on
 * controller ctrl *)
val register_cb : t -> Event.t -> (t -> Ofpacket.datapath_id -> Event.e -> unit  Lwt.t) -> unit

(** Controll channel packet transmission *)

(** [send_of_data ctrl dpid bits] send a byte packet to the switch with datapath
 * dpid throught the ctrl controller *)
val send_of_data : t -> Ofpacket.datapath_id -> Cstruct.t  -> unit Lwt.t
(** [send_data ctrl dpid pkt] send the pkt OpenFlow message to the switch with datapath
 * dpid throught the ctrl controller *)
val send_data : t -> Ofpacket.datapath_id -> Ofpacket.t  -> unit Lwt.t

(** Controller daemon setup *)

(** [init_controller init] create the state for an openflow controller and
 * initialize it using the init method *)
val init_controller : ?verbose:bool -> (t -> 'a) -> t 
(** [listen mgr addr init] listen on addr for connection switches. Intialize the
 * state for each control channel unsing the init method. *)
val listen : Manager.t -> ?verbose:bool -> Nettypes.ipv4_src -> 
  (t -> 'a) -> unit Lwt.t
(** [connect mgr addr init] connect to the switch  on addr. Intialize the
 * state of the control channel unsing the init method. *)
val connect : Manager.t -> ?verbose:bool -> Nettypes.ipv4_dst -> 
  (t -> 'a) -> unit Lwt.t
  (** [local_connect ctrl conn] connect to the switch  using a local OpenFlow
   * socket. *)
val local_connect : t -> Ofsocket.conn_state -> unit Lwt.t
