
// Keep default behaviors
const PreservedWebkit = window.webkit;
Element.prototype.preservedAddEventListener = Element.prototype.addEventListener;
Element.prototype.preservedRemoveEventListener = Element.prototype.removeEventListener;

(function(document){

  const captureMediaTag = function(node) {
    const src = extractSrc(node);
    if (!src || !/\S/.test(src)) {
      return;
    }
    const videoAttribute = 'ohajiki-video';
    if (node.getAttribute(videoAttribute)) {
      return;
    }
    node.setAttribute(videoAttribute, 1);
    // effective until iOS 9, void for iOS 10
    node.setAttribute('webkit-playsinline', true);
    node.setAttribute('playsinline', true);
    const eventName = 'play';
    node.preservedRemoveEventListener(eventName, captureMediaEvent);
    node.preservedAddEventListener(eventName, captureMediaEvent);
  };

  const captureMediaEvent = function(e) {
    const node = e.target;
    if (!node || node === 'undefined') return;
    node.webkitExitFullscreen();
    const src = extractSrc(node);
    if (!src || !/\S/.test(src)) {
      return;
    }

    // Skip video
    if (/^.+\/blank.mp4.*$/i.test(src)) {
      // might be a decoy
      return;
    } else if (/\&pltype\=adhost/i.test(src)) {
      // might be an ad
      let limit = 200;
      const timer = setInterval(function() {
        if (limit > 0
            && node
            && /\&pltype\=adhost/i.test(node.src)
            && node.duration >= 0
            && node.currentTime <= node.duration
           ) {
          limit--;
          node.currentTime = node.duration + 10.0;
        }
        else {
          clearInterval(timer);
        }
      }, 100);
      return;
    }

    node.pause();
    PreservedWebkit.messageHandlers.didGetVideoURL.postMessage(src);
  };

  const extractSrc = function(node) {
    let src = node.src;
    if (!src) {
      const source = node.querySelector("source[type='video/mp4']");
      if (source) {
        src = source.src;
      }
      else {
        const sources = node.querySelectorAll('source');
        if (sources.length > 0) {
          src = sources[0].src;
        }
      }
    }
    return src;
  };

  const didChangeAttributes = function(mutation) {
    const node = mutation.target;
    const tagName = node.nodeName;
    if (/^(audio|video)$/i.test(tagName)
        && /^src$/i.test(mutation.attributeName)
        && !mutation.oldValue) {
      captureMediaTag(node);
    }
  };

  const didChangeChildList = function(mutation) {
    let nodes = mutation.addedNodes;
    if (!nodes || typeof nodes === 'undefined' || nodes.length == 0) {
      if (mutation.target) {
        nodes = [mutation.target];
      } else {
        return;
      }
    }
    (function(mutation, nodes) {
      for (let j = 0; j < nodes.length; j++) {
        let node = nodes[j];
        if (!node || typeof node === 'undefined') continue;
        const tagName = node.tagName;
        if (!tagName || typeof tagName === 'undefined') continue;

        if (/^(video|audio)$/i.test(tagName)) {
          captureMediaTag(node);
        } else if (/^(object)$/i.test(tagName)) {
          const object = node;
          if (object.getAttribute('objectAudioPlayable')) {
            continue;
          }
          object.setAttribute('objectAudioPlayable', 1);
          let src = null;
          const param = object.querySelector('param[name=src]');
          let isAudio = false;
          if (param
              && param.value
              && /\S/.test(param.value)) {
            src = param.value;
            isAudio = object.type && /^audio/i.test(object.type);
          }
          else {
            const embed = object.querySelector('embed');
            if (embed
                && embed.src
                && /\S/.test(embed.src)) {
              src = embed.src;
              isAudio = embed.type && /^audio/i.test(embed.type);
            }
          }
          if (src) {
            // Replace <object> to <video> or <audio>
            const media = document.createElement(isAudio ? 'audio' : 'video');
            media.src = src;
            media.style.width = '100%';
            object.parentNode.replaceChild(media, object);
            captureMediaTag(media);
            continue;
          }
        } else if (node.childNodes.length > 0) {
          (function(node) {
            const videos = node.getElementsByTagName('video');
            if (videos.length > 0) {
              for (let k = 0; k < videos.length; k++) {
                const video = videos[k];
                captureMediaTag(video);
              }
            }
          })(node);
        }
      }
    })(mutation, nodes);
  };

  const observerHandler = function(mutations) {
    for (let i = 0; i < mutations.length; i++) {
      const mutation = mutations[i];
      if (!mutation || typeof mutation === 'undefined') continue;
      const mutationType = mutation.type;
      if (/attributes/i.test(mutationType)) {
        didChangeAttributes(mutation);
      } else if (/childList/i.test(mutationType)) {
        didChangeChildList(mutation);
      }
    }
  };
  const observer = new MutationObserver(observerHandler);
  const config = {
    attributes: true,
    childList: true,
    subtree: true,
    attributeFilter: ["src"]
  };
  observer.observe(document, config);

})(document);

