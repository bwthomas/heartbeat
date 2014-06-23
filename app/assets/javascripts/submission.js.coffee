class Submission
  constructor: ->
    @$node = $('.submission')
    @progressTotal = @$('.metric').length
    @setListeners()
    @setStep(6)

  $: (selector) ->
    if selector
      $(selector, @$node)
    else
      @$node

  step: 0

  nextStep: -> @setStep(@step + 1)
  prevStep: -> @setStep(@step - 1)

  setStep: (step) ->
    @step = step
    @setViewport(@step)
    @setProgress(@step)

  setViewport: (step) ->
    $metricNode = @$('.metric').eq(step)

    if $metricNode[0]
      @$().removeClass('summary').addClass('spotlight')
      @$('.metrics').animate(marginLeft: "-=#{$metricNode.position().left}")
      $('.container').removeClass('fullscreen')
    else
      @$().removeClass('spotlight').addClass('summary')
      @$('.metrics').removeAttr('style')
      $('.container').addClass('fullscreen')

  progress: 0
  progressTotal: null
  setProgress: (progress) ->
    @progress = progress
    @$('.progress .meter').animate(width: "#{@progress / @progressTotal * 100}%")

  setListeners: ->
    @$('.arrows .next').click => @nextStep()
    @$('.arrows .prev').click => @prevStep()
  
    @$('.comments-input .public').tooltip(container: 'body', delay: {show: 200, hide: 100})

    @$('.submission-toggle').click ->
      $(this).hide()
      $('.submission-form').slideDown('fast')

    @$('.rating :radio').change ->
      $(this).closest('.metric').find('.rating-value').text($(this).val())

    @$('.rating :radio').change => @nextStep()

    @$('.rating-option').click ->
      $(this).closest('.rating').add(this).addClass('rated')

    @$('.previous-rating-marker').click (e) ->
      e.preventDefault();
      e.stopPropagation();

    @$('.rating-bookend').click ->
      current_option = $(this).closest('.rating').find(':radio:checked').closest('.rating-option')

      if current_option.length
        next_option = (
          if $(this).is('.negative')
            current_option.prev('.rating-option')
          else
            current_option.next('.rating-option')
        )

        next_option.find(':radio').click()
      else
        if $(this).is('.negative')
          $(this).closest('.rating').find(':radio:first').click()
        else
          $(this).closest('.rating').find(':radio:last').click()

    $('.submission-form .comments-toggle').click ->
      $(this).hide()
      $(this).next('.comments-input').slideDown('fast')

$ -> heartbeat.submission = new Submission()
