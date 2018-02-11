let Counter = {
  init(count) {
    let timer = () =>{
      if (count > 0) document.querySelector("#time-left").innerText = --count;
    };
    setInterval(timer, 1000);
    timer();
  }
}

export default Counter;
