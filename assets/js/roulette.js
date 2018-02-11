import {Presence} from "phoenix"
import counter from "./counter"

let Roulette = {
  channel: null,
  init(socket) {
    Roulette.channel = socket.channel("roulette:lobby", {})
    Roulette.channel.join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp)
        Roulette.renderPoll(resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
    Roulette.channel.onError(e => console.log("Something went wrong", e))
    Roulette.channel.onClose(e => console.log("Channel closed", e))

    let presences = {}

    Roulette.channel.on("presence_state", state => {
      presences = Presence.syncState(presences, state);
      document.querySelector("#users-count").innerText = Object.keys(presences).length;
    })

    Roulette.channel.on("presence_diff", diff => {
      presences = Presence.syncDiff(presences, diff)
      document.querySelector("#users-count").innerText = Object.keys(presences).length;
    })

    Roulette.channel.on("sync", state => {
      Roulette.renderPoll(state)
    })
  },
  renderPoll(state) {
    counter.init(state.time)
  },
}

export default Roulette
