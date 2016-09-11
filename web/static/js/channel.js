import Isotope from "isotope-layout"

let Channel = {
  iso: null,
  userId: -1,

  init(socket, element) {
    if (!element) { return }
    socket.connect()
    let channelId = element.getAttribute("data-id")
    this.userId = parseInt(element.getAttribute("data-user-id"))
    let channel = socket.channel("channel:" + channelId)
    let authenticated = window.userToken.length > 0;

    if (authenticated) {
      let topicSubject = document.getElementById("topic-subject")
      let topicBody = document.getElementById("topic-body")
      let suggestButton = document.getElementById("topic-submit")
      suggestButton.addEventListener("click", e => {
        let payload = {
          "subject": topicSubject.value,
          "body": topicBody.value
        }
        channel
          .push("new_topic", payload)
          .receive("error", e => console.log(e))
        topicSubject.value = ""
        topicBody.value = ""
      })
      element.addEventListener("click", e => {
        let target = e.target;
        if (target.matches("span")) target = target.parentNode
        if (!target.matches("[data-id]:not(.disabled)")) return
        target.classList.toggle("disabled")
        let topicId = target.getAttribute("data-id")
        let payload = {
          "id": topicId
        }
        channel
          .push("topic_vote", payload)
          .receive("error", e => console.log(e))
      })
    }

    channel.on("new_topic", (topic) => {
      this.renderTopic(element, topic, authenticated)
    })

    channel.on("topic_update", ({id, votes}) => {
      let topic = element.querySelector(`.grid-item[data-id="${id}"]`)
      topic.setAttribute("data-votes", votes.length)
      let voteBadge = topic.querySelector(".panel-footer>span.badge")
      voteBadge.innerHTML = votes.length
      if (authenticated && votes.some(i => i.id === this.userId))
        voteBadge.nextElementSibling.classList.add("disabled")
      this.iso.updateSortData(topic)
      this.iso.arrange()
    })

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
            name: ".panel-heading",
            votes: "[data-votes] parseInt"
          },
          sortAscending: {
            votes: false,
            name: true
          },
          sortBy: ["votes", "name"]
        })
        topics.forEach(topic => this.renderTopic(element, topic, authenticated))
      })
      .receive("error", reason => console.log("join failed", reason))
  },

  esc(str) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderTopic(container, {user, id, subject, body, votes}, votingEnabled) {
    let allowVote = votes.some(i => i.id === this.userId)
      ? " disabled"
      : ""
    let vote = votingEnabled
      ? `&nbsp;<button type="button" class="btn btn-xs btn-success${allowVote}" aria-label="Vote!" data-id="${id}">
  <span class="glyphicon glyphicon-ok-circle" aria-hidden="true"></span>
</button>`
      : ""
    let template = document.createElement("div")
    template.classList.add("grid-item", "col-xs-6", "col-sm-4", "col-md-3")
    template.setAttribute("data-id", id)
    template.setAttribute("data-votes", votes.length)
    template.innerHTML = `
    <div class="grid-item-content panel panel-info">
      <div class="panel-heading">${this.esc(subject)}</div>
      <div class="panel-body">${body ? this.esc(body) : "<i>no detail</i>"}</div>
      <div class="panel-footer">
        By: <em>${user.username}</em></br>
        Voting: <span class="badge">${votes.length}</span>${vote}
      </div>
    </div>
    `
    container.appendChild(template)
    this.iso.appended(template)
    this.iso.arrange()
  }
}
export default Channel
