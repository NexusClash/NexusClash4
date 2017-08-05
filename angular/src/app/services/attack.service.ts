import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import 'rxjs/add/operator/startWith';
import 'rxjs/add/operator/take';

import { Attack } from '../models/attack';
import { ChargeAttack } from '../models/charge-attack';
import { Character } from '../models/character';
import { Packet } from '../models/packet';
import { PacketService } from './packet.service';
import { SocketService } from './socket.service';

@Injectable()
export class AttackService extends PacketService {

  private targetId: number;

  availableAttacks = new Subject<Attack[]>();
  availableAbilities = new Subject<{name:string,id:number}[]>();
  availableChargeAttacks = new Subject<ChargeAttack[]>();

  handledPacketTypes = ["actions", "message"];

  constructor(
    protected socketService: SocketService
  ) {
    super(socketService);
  }

  handle(packet: Packet): void {
    this.deserializeAttacks(packet);
    this.deserializeChargeAttacks(packet);
    this.deserializeAbilities(packet);
  }

  selectTarget(characterId: number): void {
    this.targetId = characterId;
    this.send(new Packet('select_target', { char_id: characterId }));
  }

  attack(actionId: number, chargeAttackId: number): void {
    var attackPacket = new Packet('attack', {
      target_type: 'character',
      target: this.targetId,
      weapon: actionId
    });
    if(chargeAttackId){
      attackPacket["charge_attack"] = chargeAttackId;
    }
    this.send(attackPacket);
  }

  useAbility(actionId: number): void {
    this.send(new Packet('activate_target', {
      target_type: 'character',
      target: this.targetId,
      status_id: actionId
    }));
  }

  private deserializeAttacks(packet: Packet): void {
    let availableAttacks = [];
    let attacks = packet["actions"].attacks;
    for(let attackId in attacks){
      let attack = attacks[attackId];
      attack["id"] = attackId;
      availableAttacks.push(new Attack(attack));
    }
    this.availableAttacks.next(availableAttacks);
  }

  private deserializeAbilities(packet: Packet): void {
    let availableAbilities = [];
    let abilities = packet["actions"].abilities;
    for(let abilityId in abilities){
      let ability = abilities[abilityId];
      ability["id"] = abilityId;
      availableAbilities.push(ability);
    }
    this.availableAbilities.next(availableAbilities);
  }

  private deserializeChargeAttacks(packet: Packet): void {
    let availableChargeAttacks = [];
    let chargeAttacks = packet["actions"].charge_attacks;
    for(let chargeAttackId in chargeAttacks){
      let chargeAttack = chargeAttacks[chargeAttackId];
      chargeAttack["id"] = chargeAttackId;
      availableChargeAttacks.push(new ChargeAttack(chargeAttack));
    }
    this.availableChargeAttacks.next(availableChargeAttacks);
  }
}