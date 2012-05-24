#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
begin
  require 'TT_Lib2/core.rb'
rescue LoadError => e
  timer = UI.start_timer( 0, false ) {
    UI.stop_timer( timer )
    filename = File.basename( __FILE__ )
    message = "#{filename} require TT_Lib² to be installed.\n"
    message << "\n"
    message << "Would you like to open a webpage where you can download TT_Lib²?"
    result = UI.messagebox( message, MB_YESNO )
    if result == 6 # YES
      UI.openURL( 'http://www.thomthom.net/software/tt_lib2/' )
    end
  }
end


#-------------------------------------------------------------------------------

if defined?( TT::Lib ) && TT::Lib.compatible?( '2.7.0', 'Attributes Browser' )

module TT::Plugins::AttributesBrowser
  
  
  ### CONSTANTS ### ------------------------------------------------------------
  
  # Plugin information
  PLUGIN_ID       = 'TT_AttributesBrowser'.freeze
  PLUGIN_NAME     = 'Attributes Browser'.freeze
  PLUGIN_VERSION  = TT::Version.new(1,0,0).freeze
  
  # Version information
  RELEASE_DATE    = '24 May 12'.freeze
  
  # Resource paths
  PATH_ROOT   = File.dirname( __FILE__ ).freeze
  PATH        = File.join( PATH_ROOT, 'TT_AttributesBrowser' ).freeze
  
  
  ### VARIABLES ### ------------------------------------------------------------
  
  #@module_variable = 'Hello World'
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    # Menus
    m = TT.menu( 'Window' )
    m.add_item( 'Attributes' ) { self.toggle_attributes_window }
    
    # Context menu
    UI.add_context_menu_handler { |context_menu|
      self.edit_attributes
    }
    
    # Toolbar
    #toolbar = UI::Toolbar.new( PLUGIN_NAME )
    #toolbar.add_item( ... )
    #if toolbar.get_last_state == TB_VISIBLE
    #  toolbar.restore
    #  UI.start_timer( 0.1, false ) { toolbar.restore } # SU bug 2902434
    #end
  end 
  
  
  ### LIB FREDO UPDATER ### ----------------------------------------------------
  
  def self.register_plugin_for_LibFredo6
    {   
      :name => PLUGIN_NAME,
      :author => 'thomthom',
      :version => PLUGIN_VERSION.to_s,
      :date => RELEASE_DATE,   
      :description => 'Browse and edit model and entity attributes.',
      :link_info => 'http://forums.sketchucation.com/viewtopic.php?f=0&t=0'
    }
  end
  
  
  ### MAIN SCRIPT ### ----------------------------------------------------------
  
  # @return [String]
  # @since 1.0.0
  def self.toggle_attributes_window
    # ...
  end
  
  # @return [String]
  # @since 1.0.0
  def self.edit_attributes
    # ...
  end

  
  ### DEBUG ### ----------------------------------------------------------------
  
  # @note Debug method to reload the plugin.
  #
  # @example
  #   TT::Plugins::AttributesBrowser.reload
  #
  # @param [Boolean] tt_lib
  #
  # @return [Integer]
  # @since 1.0.0
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    TT::Lib.reload if tt_lib
    # Core file (this)
    load __FILE__
    # Supporting files
    #x = Dir.glob( File.join(PATH, '*.{rb,rbs}') ).each { |file|
    #  load file
    #}
    x.length
  ensure
    $VERBOSE = original_verbose
  end

end # module TT::Plugins::AttributesBrowser

end # if TT_Lib

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------