// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery(function() {
  $('a.add-row').live('click', function() {
    var filterRow = $('form#smart-filter fieldset.filter:first').clone();
    $('#filters').append(filterRow);
    return false;
  });

  $('a.remove-row').live('click', function() {
    if ($('form#smart-filter fieldset.filter').length > 1) {
      var currentFilterRow = $(this).parent().parent();
      currentFilterRow.remove();
    };
    return false;
  });

  var dropDownToShow = $('select.columns option:selected').val();
  $('span.criteria').hide();
  $('.' + dropDownToShow + '-criteria').show();

  $('select.columns').live('change', function() {
    var dropDownToShow = $(this).find('option:selected').val();
    $(this).parent().children('span.criteria').hide();
    $(this).parent('fieldset.filter').children('span.' + dropDownToShow + '-criteria').show();
  });

  $('select.criteria-dropdown').live('change', function() {
    if (($(this).val() == 'between') && ($(this).parent().find('input').length < 2)) 
    {
      $(this).parent().find('input').first().clone().appendTo($(this).parent());
      $(this).parent().find('input').addClass('between-input');
    } 
    else if (($(this).val() != 'between') && ($(this).parent().find('input').length > 1)) 
    {
      $(this).parent().find('input').last().remove();
      $(this).parent().find('input').removeClass('between-input');
    };
  });

  $('#smart-filter').submit(function() {
    $('.filter').each(function(index) {
      $(this).find('span select').each(function(index) {
        if ($(this).val() == '') {
          $(this).parent().remove();
        };
      });
      $(this).find('span input').each(function(index) {
        if ($(this).val() == '') {
          $(this).parent().remove();
        }; 
      });
    });
  });
});
