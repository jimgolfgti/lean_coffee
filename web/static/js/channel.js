import Isotope from "isotope-layout"
import {Presence} from "phoenix"

let Channel = {
  iso: null,
  userId: -1,

  init(socket, element, $) {
    if (!element) { return }
    socket.connect()
    const channelId = element.getAttribute("data-id")
    this.userId = parseInt(element.getAttribute("data-user-id"))
    const channel = socket.channel("channel:" + channelId)
    const authenticated = window.userToken.length > 0;

    if (authenticated) {
      const $topicSubject = $("#topic-subject")
      const $topicBody = $("#topic-body")
      $("#topic-submit").on("click", () => {
        const payload = {
          "subject": $topicSubject.val(),
          "body": $topicBody.val()
        }
        channel
          .push("new_topic", payload)
          .receive("error", ({errors}) => {
            for (let key of ["subject", "body"]) {
              const hasError = errors.hasOwnProperty(key)
              const field = $(`#topic-${key}`)
                .parent()
                .toggleClass("has-error", hasError)
                .end()
              if (hasError) {
                const msg = errors[key].join("<br/>")
                field
                  .attr("data-content", msg)
                  .popover({
                    "trigger": "focus hover",
                    "container": "body",
                    "placement": "auto bottom"
                  })
              }
              else {
                field.popover("destroy")
              }
            }
          })
          .receive("ok", () => {
            $topicSubject
              .popover("destroy")
              .val("")
              .removeClass("has-error")
            $topicBody
              .popover("destroy")
              .val("")
              .parent()
              .removeClass("has-error")
          })
      })
      element.addEventListener("click", e => {
        let target = e.target;
        if (target.matches(".panel-heading")) {
          let topic = $(target.parentNode);
          $("#view-modal")
            .find(".modal-title")
            .html("<strong>Topic:</strong> " + topic.find(".panel-heading").html())
            .end()
            .find(".modal-body")
            .html("<strong>Details:</strong> " + topic.find(".panel-body").html())
            .end()
            .modal()
          return
        }
        if (target.matches("span")) target = target.parentNode
        if (!target.matches("[data-topic-id]:not(.disabled)")) return
        target.classList.toggle("disabled")
        const topicId = target.getAttribute("data-topic-id")
        const payload = {
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
      const topic = element.querySelector(`.grid-item[data-id="${id}"]`)
      topic.setAttribute("data-votes", votes.length)
      const voteBadge = topic.querySelector(".panel-footer>span.badge")
      voteBadge.innerHTML = votes.length
      if (authenticated && votes.some(i => i.id === this.userId))
        voteBadge.nextElementSibling.classList.add("disabled")
      this.iso.updateSortData(topic)
      this.iso.arrange()
    })

    const listBy = (key, {metas: metas, user}) => {
      return {
        user: parseInt(key) === this.userId ? "You" : user,
        onlineAt: metas[0].online_at
      }
    }
    const formatTimestamp = (timestamp) => {
      const date = new Date(timestamp)
      return date.toLocaleTimeString()
    }

    const userList = document.getElementById("user-list")
    const render = (presences) => {
      const items = Presence.list(presences, listBy)
        .sort((a, b) => {
          return b.onlineAt - a.onlineAt
        })
        .map(presence => `
          <dt>${presence.user}</dt>
          <dd>joined at ${formatTimestamp(presence.onlineAt)}</dd>
        `)
        .join("")
      userList.innerHTML = `<dl class="dl-horizontal">${items}</dl>`
    }

    let presences = {}
    channel.on("presence_state", state => {
      presences = Presence.syncState(presences, state)
      render(presences)
    })

    channel.on("presence_diff", diff => {
      presences = Presence.syncDiff(presences, diff)
      render(presences)
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
    const div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderTopic(container, {user, id, subject, body, votes}, votingEnabled) {
    let allowVote = votes.some(i => i.id === this.userId)
      ? " disabled"
      : ""
    let vote = votingEnabled
      ? `&nbsp;<button type="button" class="btn btn-xs btn-success${allowVote}" aria-label="Vote!" data-topic-id="${id}">
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
