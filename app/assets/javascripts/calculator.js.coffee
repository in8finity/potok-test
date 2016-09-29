# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class InvestmentCalculator
	debounce: (threshold, execAsap, func) ->
	  timeout = null
	  (args...) =>
	    obj = this
	    delayed = =>
	      func.apply(obj, args) unless execAsap
	      timeout = null
	    if timeout
	      clearTimeout(timeout)
	    else if (execAsap)
	      func.apply(obj, args)
	    timeout = setTimeout delayed, threshold || 100

	requestRealInterest: () ->
		invested_value = document.getElementById("invested_value").value
		$("calculation_result__real_interest_section").addClass("loading")
		$.get("/calculator.json",{invested_value: invested_value}, (data) =>
			console.log("Success")
			console.log(data)
			@updateValuesOnForm(data);
		)
		      
	updateInterestsValues: ()->
		@requestRealInterest()
		return true

	updateValuesOnForm: (interest_values_data)->
		currency = interest_values_data.currency
		@real_interest_value_element.html(interest_values_data.real_interest+"&nbsp;"+currency)
		@planned_interest_value_element.html(interest_values_data.planned_interest+"&nbsp;"+currency)
		#probably later we will get rates from the server depending on the pricing strategy
		@planned_interest_rate_element.html(interest_values_data.planned_interest_rate)
		@real_interest_rate_element.html(interest_values_data.planned_interest_rate)
		@real_interest_rate_element.html((interest_values_data.real_interest/interest_values_data.invested_value*100.0).toLocaleString()+"%")
		@real_interest_value_element.removeClass("loading");

	onValueUpdate: ()->
		console.log("Updating")
		@updateInterestsValues()
		return false

	bindEvents: ()->
		$("#invested_value").on "change", @debounce(100, false, @onValueUpdate)
		$("#invested_value").on "keyup", @debounce(100, false, @onValueUpdate)
	
	constructor: ()->
		@real_interest_rate_element = $(".calculation_result__real_interest_rate")
		@real_interest_value_element = $(".calculation_result__real_interest_value")
		@planned_interest_rate_element = $(".calculation_result__planned_interest_rate")
		@planned_interest_value_element = $(".calculation_result__planned_interest_value")
		@bindEvents()

$(document).ready ()->
	investment_calculator = new InvestmentCalculator()