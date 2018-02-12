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
    Roulette.channel.on("result", result => {
      Roulette.renderResult(result)
    })
  },
  renderPoll(state) {
    counter.init(state.time)
    let options = document.querySelector("#options")
    options.innerHTML = ""
    for (var option in state.poll) {
      options.innerHTML += Roulette.rederOption(option, state.poll[option])
    }

    let buttons = document.getElementsByClassName('option');
    for(var i = 0; i < buttons.length; i++) {
      (function(i) {
        buttons[i].addEventListener('click', function() {
          Roulette.channel.push("vote", {vote: this.dataset.value})
        }, false);
      })(i);
    }
  },
  rederOption(option, count) {
    return `
    <div class="column">
      <a class="button is-info option" data-value="${option}">${option} (${count})</a>
    </div>
    `
  },
  renderResult(result) {
    let winner = document.querySelector("#result #winner")
    winner.innerText = result.winner + " WINS!"
    let img = document.querySelector("#result img")
    img.src = result.url
  },
}

export default Roulette
