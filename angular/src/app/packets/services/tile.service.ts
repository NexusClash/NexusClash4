import { Packet } from '../packet';
import { PacketHandler } from '../packet-handler';
import { Tile } from '../tile';

export class TileService implements PacketHandler {

  tiles: Map<String,Tile> = new Map<String,Tile>();
  tile_css: Map<String,String> = new Map<String,String>();

  isHandlerFor(packet: Packet): boolean {
    return ["tile"].includes(packet.type);
  }

  handle(packet: Packet): void {
    if(packet.type == "tile"){
      let tile = Object.assign(new Tile(), packet["tile"]);
      this.tiles.set(tile.id, tile);
    }
  }

  tile(x, y, z, plane): Tile {
    let tile_id = [x, y, z, plane].join(",");
    return this.tiles.has(tile_id)
      ? this.tiles.get(tile_id)
      : null;
  }
}
