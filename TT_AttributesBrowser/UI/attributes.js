var AttributesWindow = function() {
  return {
  
  
    init : function() {
      var $title = $( '<h1>No Entity Selected</h1>' );
      $('body').append( $title );
      AttributesWindow.empty();
      //Sketchup.callback( 'Update_Attributes' );
      window.location = 'skp:Update_Attributes';
    },
    
    add_dictionary : function( title, attributes ) {
      var $group  = $('<dl class="dictionary"></dl>');
      var $header = $('<dt>' + title + '</dt>');
      var $attributes = $('<dd></dd>');
      
      $header.on( 'click', function() {
        $attributes.slideToggle( 'fast' );
      });
      $header.css( 'cursor', 'pointer' );
      
      var $table = $( '<table></table>' );
      var $colgroup = $( '<colgroup></colgroup>' );
      $colgroup.append( $( '<col width="35%" />' ) );
      $colgroup.append( $( '<col width="*" />' ) );
      $colgroup.append( $( '<col width="40" />' ) );
      $table.append( $colgroup );
      for ( key in attributes ) {
        value = attributes[ key ];
        type = '[' + $.type( value ) + ']';
        $row = $( '<tr></tr>' );
        $row.append( $('<td class="key">' + key + '</td>') );
        $row.append( $('<td class="value">' + value + '</td>') );
        $row.append( $('<td>' + type + '</td>') );
        $table.append( $row );
      }
      $attributes.append( $table );
      
      $group.append( $header );
      $group.append( $attributes );
      $('body').append( $group );
    },
    
    entity : function( entity_name ) {
      $('h1').text( entity_name );
    },
    
    empty : function() {
      $('body').append( '<i class="message">No Dictionaries</i>' );
    },
    
    clear : function() {
      $('.dictionary, .message').remove();
    }
    
    
  };
  
  /* PRIVATE */
  
  // ...
  
}(); // AttributesWindow

$(document).ready( AttributesWindow.init );