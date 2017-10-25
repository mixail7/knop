((DOC) ->
  STORAGE_KEY = 'knop_highlight_phrase'
  DELIMITER = "\u0840"
  DELIMITER_TRANSLATION = "\u0841"
  WORD_MAX_LENGTH_LIMIT = 50
  WAITING_COUNT = 500

  log = (str) ->
    console.log(str)

  get_translation_from_google_dic = ->
    try
      word = DOC.querySelector("#gdx-bubble-host")
        .shadowRoot
        .querySelector("#gdx-bubble-query")
        .innerText
      translation = DOC.querySelector("#gdx-bubble-host")
        .shadowRoot
        .querySelector("#gdx-bubble-meaning")
        .innerText.split(',')[0]
      if word.length > WORD_MAX_LENGTH_LIMIT || translation > WORD_MAX_LENGTH_LIMIT
        log("invalid word #{word} or translation #{translation}")
        null
      else
        [word, translation]
    catch
      null

  add_word_to_dictionary = (elem) ->
    google_dic_finding =
      start: ->
        @timer_id = setInterval(@wait, 10)
        @count_timer_step = 0
      stop: ->
        clearInterval(@timer_id) if(@timer_id)
      wait: ->
        elem = DOC.querySelector("#gdx-bubble-host")
        if (elem && elem.shadowRoot.querySelector("#gdx-bubble-more")) || @count_timer_step > WAITING_COUNT
          google_dic_finding.stop()
          result = get_translation_from_google_dic()
          log(result)
          add_phrase_to_storage(result[0], result[1]) if result
        else
          @count_timer_step += 1
    google_dic_finding.start()

  highlight_phrase = (phrases) ->
    html = DOC.body.innerHTML
    for phrase in phrases
      next if phrase.length == 0
      html = html.replace ///#{phrase}///g, "<span class='knop_highlight_phrase'>#{phrase}</span>"
    DOC.body.innerHTML = html

  highlight_phrase ["Examples"]

  add_phrase_to_storage = (word, translation) ->
    chrome.storage.sync.get STORAGE_KEY,
      (item) ->
        if !chrome.runtime.error
          new_data = item.data || {}
          new_data[word] = translation
          chrome.storage.sync.set("#{STORAGE_KEY}": new_data)

  DOC.addEventListener("dblclick", add_word_to_dictionary)) document
