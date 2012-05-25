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
  PATH_UI     = File.join( PATH, 'UI' ).freeze
  
  
  ### VARIABLES ### ------------------------------------------------------------
  
  @wnd_attributes = nil
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    # Menus
    m = TT.menu( 'Window' )
    m.add_item( 'Attributes' ) { self.toggle_attributes_window }
    
    # Context menu
    UI.add_context_menu_handler { |context_menu|
      context_menu.add_item( 'Edit Attributes' ) { self.edit_attributes }
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
    # (!) Implement toggle.
    @wnd_attributes ||= self.create_attributes_window
    if @wnd_attributes.visible?
      @wnd_attributes.bring_to_front
    else
      @wnd_attributes.show_window
    end
  end
  
  # @return [String]
  # @since 1.0.0
  def self.edit_attributes
    model = Sketchup.active_model
    window = @wnd_attributes
    
    #puts '<Edit Attributes>'
    #puts '> Clearing Window...'
    window.call_script( 'AttributesWindow.clear' )
    
    if model.selection.empty?
      entity = model
    elsif model.selection.length == 1
      entity = model.selection[0]
    elsif model.selection.is_curve?
      # (!) One segment curve?
      entity = model.selection[0].curve
    else
      window.call_script( 'AttributesWindow.empty' )
      #puts 'Invalid selection!.'
      UI.beep
      return
    end
    
    window.call_script( 'AttributesWindow.entity', entity.inspect )
    
    # (!) ComponentDefinition
    # (!) Curve ( selection.is_curve? )
    
    if entity.attribute_dictionaries.nil?
      window.call_script( 'AttributesWindow.empty' )
      #puts 'No dictionaries!'
      UI.beep
      return
    end
    
    for dictionary in entity.attribute_dictionaries
      add_dictionary = 'AttributesWindow.add_dictionary'
      attributes = {}
      dictionary.each_pair { | key, value |
        attributes[key] = value
        # (!) Custom Handling
        #     * Geom::Point3d
        #     * Geom::Vector3d
        #     * ???
      }
      window.call_script( add_dictionary, dictionary.name, attributes )
    end
    
    #puts '</Edit Attributes>'
  end
  
  # @return [String]
  # @since 1.0.0
  def self.create_attributes_window
    puts 'Creating Attributes Window...'
    options = {
      :title      => 'Attributes',
      :pref_key   => PLUGIN_ID,
      :scrollable => false,
      :resizable  => true,
      :width      => 400,
      :height     => 500,
      :left       => 200,
      :top        => 100
    }
    window = TT::GUI::ToolWindow.new( options )
    window.add_script( File.join( 'file:///', PATH_UI, 'attributes.js' ) )
    window.add_style(  File.join( 'file:///', PATH_UI, 'window.css' )    )
    
    window.add_action_callback( 'Update_Attributes' ) { |dialog, params|
      #puts "Update_Attributes()"
      self.selection_changed( Sketchup.active_model.selection )
      self.observe_models
    }
    
    window.set_on_close {
      #puts 'Window Closing...'
      # Detach observers.
      if @app_observer
        Sketchup.remove_observer( @app_observer )
      end
      if @selection_observer
        Sketchup.active_model.selection.remove_observer( @selection_observer )
      end
    }
    
    window
  end
  
  # @param [Sketchup::Selection] selection
  #
  # @since 1.0.0
  def self.selection_changed( selection )
    #puts "Selection Changed (#{selection.length})"
    if @wnd_attributes && @wnd_attributes.visible?
      self.edit_attributes
    end
  end
  
  
  # @param [Sketchup::Model] model
  #
  # @since 1.0.0
  def self.observe_selection( model )
    #puts '> Attaching Selection Observer'
    @selection_observer ||= SelectionObserver.new { |selection|
      self.selection_changed( selection )
    }
    model.selection.remove_observer( @selection_observer ) if @selection_observer
    model.selection.add_observer( @selection_observer )
  end
  
  
  # @since 1.0.0
  def self.observe_models
    #puts 'Observing current model'
    @app_observer ||= AppObserver.new
    Sketchup.remove_observer( @app_observer ) if @app_observer
    Sketchup.add_observer( @app_observer )
    self.observe_selection( Sketchup.active_model )
    #puts '---'
  end
  
  
  # @since 1.0.0
  class SelectionObserver < Sketchup::SelectionObserver
    
    # @since 1.0.0
    def initialize( &block )
      @proc = block
    end
    
    # @since 1.0.0
    def onSelectionBulkChange( selection )
      selectionChanged( selection )
    end
    
    # @since 1.0.0
    def onSelectionCleared( selection )
      selectionChanged( selection )
    end
    
    # @param [Sketchup::Selection] selection
    #
    # @since 1.0.0
    def selectionChanged( selection )
      #puts "\n[Event] Selection Changed (#{Time.now.to_i})"
      @proc.call( selection )
    end
    
  end # class SelectionObserver
  
  
  # @since 1.0.0
  class AppObserver < Sketchup::AppObserver
    
    # @since 1.0.0
    def onNewModel( model )
      #puts 'onNewModel'
      TT::Plugins::AttributesBrowser.observe_selection( model )
    end
    
    # @since 1.0.0
    def onOpenModel( model )
      #puts 'onOpenModel'
      TT::Plugins::AttributesBrowser.observe_selection( model )
    end
    
  end # class AppObserver

  
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
    x = Dir.glob( File.join(PATH, '*.{rb,rbs}') ).each { |file|
      load file
    }
    x.length
  ensure
    $VERBOSE = original_verbose
  end

end # module TT::Plugins::AttributesBrowser

end # if TT_Lib

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------