let Channel = {
  iso: null,

  init(socket, element, Isotope) {
    if (!element) { return }
    socket.connect()
    let channelId = element.getAttribute("data-id")
    let topicSubject = document.getElementById("topic-subject")
    let topicBody = document.getElementById("topic-body")
    let suggestButton = document.getElementById("topic-submit")
    let channel = socket.channel("channel:" + channelId)

    suggestButton && suggestButton.addEventListener("click", e => {
      let payload = {
        subject: topicSubject.value,
        body: topicBody.value
      };
      channel
        .push("new_topic", payload)
        .receive("error", e => console.log(e))
      topicSubject.value = ""
      topicBody.value = ""
    });

    channel.on("new_topic", (resp) => {
      this.renderTopic(element, resp)
    });

    channel.join()
      .receive("ok", ({topics}) => {
        element.innerHTML = "<div class=\"grid-sizer col-xs-6 col-sm-4 col-md-3\"></div>"
        this.iso = new Isotope(element, {
          itemSelector: ".grid-item",
          percentPosition: true,
          masonary: {
            columnWidth: ".grid-sizer"
          },
          getSortData: {
            name: ".panel-heading"
          }
        })
        topics.forEach(topic => this.renderTopic(element, topic))
      })
      .receive("error", reason => console.log("join failed", reason))
  },

  esc(str) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderTopic(container, {user, subject, body}) {
    let template = document.createElement("div")
    template.classList.add("grid-item", "col-xs-6", "col-sm-4", "col-md-3")
    template.innerHTML = `
    <div class="grid-item-content panel panel-default">
      <div class="panel-heading">
        ${this.esc(subject)}
      </div>
      <div class="panel-body">
        ${body ? this.esc(body) : ""}
      </div>
    </div>
    `
    container.appendChild(template)
    this.iso.appended(template)
    this.iso.arrange({
      sortBy: [ "name" ]
    })
  }
}
export default Channel
