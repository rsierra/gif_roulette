import {Presence} from "phoenix"

let Roulette = {
  init(socket) {
    let channel = socket.channel("roulette:lobby", {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
    channel.onError(e => console.log("Something went wrong", e))
    channel.onClose(e => console.log("Channel closed", e))

    let presences = {}

    channel.on("presence_state", state => {
      presences = Presence.syncState(presences, state);
      document.querySelector("#users-count").innerText = Object.keys(presences).length;
    })

    channel.on("presence_diff", diff => {
      presences = Presence.syncDiff(presences, diff)
      document.querySelector("#users-count").innerText = Object.keys(presences).length;
    })
  }
}

export default Roulette
