/**
Parchment Transcript Recording Plugin
	* Version 1.0
	* URL: http://code.google.com/p/parchment-transcript/
	* Description: Parchment Transcript Recording Plugin sends transcripts of games being played on Parchment web interpreter to a remote server.
	* Author: Juhana Leinonen
	* Copyright: Copyright (c) 2011 Juhana Leinonen under MIT license.
**/

var ifRecorder = {
		sessionId: (new Date().getTime())+""+( Math.ceil( Math.random() * 1000 ) ),
		command: { input: '', timestamp: 0 },
		output: '',
		cache: [],
		statusline: '',
		window: 0,	// which window the transcript has been saved to

		/* Turn count is the game's internal turn counter
		 * input count is the number of actual input given by the player
		 * output count is the number of packets sent to the server
		 */
		turncount: 0,	// turncount is currently unused since we don't have means to access game's turn count. 
		inputcount: 0,
		outputcount: 1,
		styles: '',
		saveUrl: '',
		story: {
		    name: '',
		    version: ''
		},
		// additional information saved with the transcript
		info: '', 
		
		// currently Undum and Parchment are supported 
		interpreter: ( typeof parchment != 'undefined' ? 'Parchment' : 'Undum' ),

		// the player can opt out by having feedback=0 in the url
		optOut: ( typeof( getUrlVars()[ 'feedback' ] ) != 'undefined' && getUrlVars()[ 'feedback' ] != '1' ),
		
		// is the transcript saving server offline?
		serverOffline: false,
		
		/*
		 * Send the transcript collected so far
		 */
		send: function( window, styles, text, cache ) {
			var self = this;
			
			if( !this.collectTranscripts() ) {
				return;
			}
			
			if( typeof( window ) != 'undefined' ) {
				self.window = window;
			}
			if( typeof( styles ) != 'undefined' ) {
				self.styles = styles;
			}
			if( typeof( text ) != 'undefined' ) {
				self.output = text;
			}
					
			var sendData = {
			   'session': self.sessionId,
			   'log': {
			         'inputcount': self.inputcount,
			         'outputcount': self.outputcount,
			         'input': self.command.input,
			         'output': self.output,
			         'window': self.window,
			         'styles': self.styles,
			      }
			};
						
			if( cache ) {
				self.cache.push( sendData );
			}
			else {

				if( self.cache.length > 0 ) {
					self.cache.push( sendData );
					sendData = self.cache;
					self.cache = [];
				}
				
				
				jQuery.ajax( {
					type: 'POST',
					url: self.saveUrl,
					contentType: 'application/json',
					data: JSON.stringify( { data: sendData } )
				} );
			}

			// clearing the buffer for next turn
			self.output = '';
			self.outputcount++;
		},
		
		/*
		 * Send the collected cache
		 */
		sendCache: function() {
			var self = this;
			
			if( this.collectTranscripts() && self.cache.length > 0 ) {

				jQuery.ajax( {
					type: 'POST',
					url: self.saveUrl,
					contentType: 'application/json',
					data: JSON.stringify( { data: self.cache } )
				} );
				self.cache = [];
			}
		},
		
		/*
		 * Check whether we should collect transcript information. 
		 * Transcripts are collected if:
		 *  - we know the url where to send the transcripts
		 *  - the player hasn't opted out with feedback=0 option
		 */
		collectTranscripts: function() {
			if( this.saveUrl == '' || this.optOut || this.serverOffline ) {
				return false;
			}
			return true;
		},
		
		initialize: function( url ) {
			var self = this;
			
			if( typeof url == 'string' ) {
				self.saveUrl = url;
			}
			
			// Fill story name + version from Undum variables
			if( typeof undum != 'undefined' ) {
			    if( self.story.name == '' ) {
			        self.story.name = undum.game.id;
			    }
			    
			    if( self.story.version == '' ) {
			        self.story.version = undum.game.version;
			    }
			}

			// If story name hasn't been given, set it to the file name.
			// This will not work with the archive search thing.
			if( self.story.name == '' ) {
				if( typeof( parchment.options.default_story ) != 'undefined' && parchment.options.default_story != '' ) {
					self.story.name = parchment.options.default_story;
					
					if( !parchment.options.lock_story && typeof( getUrlVars()[ 'story' ] ) != 'undefined' && getUrlVars()[ 'story' ] != '' ){
						self.story.name = getUrlVars()[ 'story' ];
					} 
				}
				else {
					if( !parchment.options.lock_story && typeof( getUrlVars()[ 'story' ] ) != 'undefined' && getUrlVars()[ 'story' ] != '' ){
						self.story.name = getUrlVars()[ 'story' ];
					} 
				}
			}
			
			if( self.story.name == '' ) {
				self.story.name = '(unknown)';
			}
			
			if( !self.collectTranscripts() ) {
				return false;
			}
				
			return true;
		},
		
		charName: function( keyCode ) {
			// the hex values are Glulx keycodes
			switch( keyCode ) { 
		    	case Event.KEY_BACKSPACE:
					return '<backspace>';
		    	case 0xfffffff9:
		    		return '<backspace/delete>'; // apparently Glulx doesn't make a difference
			    case Event.KEY_TAB:
			    case 0xfffffff7:
					return '<tab>';
				case 13:
				case 0xfffffffa:
					return '<enter>';
			    case Event.KEY_ESC:
			    case 0xfffffff8:
					return '<esc>';
				case 32:
					return '<space>';
			    case Event.KEY_LEFT:
			    case 0xfffffffe:
					return '<left>';
			    case Event.KEY_UP:
			    case 0xfffffffc:
					return '<up>';
			    case Event.KEY_RIGHT:
			    case 0xfffffffd:
					return '<right>';
			    case Event.KEY_DOWN:
			    case 0xfffffffb:
			    	return '<down>';
				case 46:
					return '<del>';
			    case Event.KEY_PAGEUP:
			    case 0xfffffff6:
			    	return '<pgup>';
			    case Event.KEY_PAGEDOWN:
			    case 0xfffffff5:
			    	return '<pgdown>';
			    case Event.KEY_HOME:
			    case 0xfffffff4:
			    	return '<home>';
			    case Event.KEY_END:
			    case 0xfffffff3:
			    	return '<end>';
			    case 0xffffffef:
			    	return '<F1>';
			    case 0xffffffee:
			    	return '<F2>';
			    case 0xffffffed:
			    	return '<F3>';
			    case 0xffffffec:
			    	return '<F4>';
			    case 0xffffffeb:
			    	return '<F5>';
			    case 0xffffffea:
			    	return '<F6>';
			    case 0xffffffe9:
			    	return '<F7>';
			    case 0xffffffe8:
			    	return '<F8>';
			    case 0xffffffe7:
			    	return '<F9>';
			    case 0xffffffe6:
			    	return '<F10>';
			    case 0xffffffe5:
			    	return '<F11>';
			    case 0xffffffe4:
			    	return '<F12>';
				default:
					return String.fromCharCode( keyCode );
			}
			
		},
		
		/**
		 * Undum-specific functions
		 */
		undum: {
		    oldContentLength: 0,
		    prepare: function( link ) {
		        var self = ifRecorder;
		        self.command.input = link;
		        this.oldContentLength = jQuery( '#content' ).html().length;
		    },
		    send: function( link ) {
		        var self = ifRecorder;
		        self.inputcount++;
		        self.output = jQuery( '#content' ).html().substring( this.oldContentLength );
		        self.send();
		    }
		}
};


jQuery( document ).ready(function($){

/* save commands when Parchment calls the hooks in [z]ui.js */
$( document ).bind( 
		'LineInput', 
		function( command ) {
//			console.log( 'cmd: '+command.toSource() );
		    ifRecorder.command = command;
		    ifRecorder.inputcount++;
		} 
	);

$( document ).bind( 
		'CharInput', 
		function( command ) { 
		//	console.log( 'charcmd: '+command.toSource() );
		    ifRecorder.command = command;
		    ifRecorder.command.input = ifRecorder.charName( command.input.keyCode );
		    ifRecorder.inputcount++;
		} 
	);

// Sending main game texts to the recorder.
// Status line is saved by the modified Console.renderHtml().
$( document ).bind(
		'TextOutput',
		function( data ) {
			if( data.output.window == 0 ) {
			    ifRecorder.send( data.output.window, data.output.styles, data.output.text );
			}
		}
);

// Glk text output saving
$( document ).bind(
		'GlkOutput',
		function( data ) {
		
			if( typeof data.output === 'undefined' ) {
				return;
			}

			for( var i = 0; i < data.output.length; ++i ) {
				if( typeof data.output[ i ].text !== 'undefined' ) {
					for( var j = 0; j < data.output[ i ].text.length; ++j ) {
						ifRecorder.styles = '';
						ifRecorder.output = "\n";
						
						if( typeof( data.output[ i ].text[ j ].content ) != 'undefined' ) {
							for( var k = 0; k < data.output[ i ].text[ j ].content.size(); k += 2 ) {
								ifRecorder.styles = data.output[ i ].text[ j ].content[ k ];
								ifRecorder.output = data.output[ i ].text[ j ].content[ k+1 ];
								if( k == data.output[ i ].text[ j ].content.size() - 2 ) {
									ifRecorder.output += "\n";
								}
								ifRecorder.send( ifRecorder.window, ifRecorder.styles, ifRecorder.output, true );
							}
						}
						else {
							ifRecorder.send( ifRecorder.window, ifRecorder.styles, ifRecorder.output, true );
						}
					}
				}
			}
			ifRecorder.sendCache();
		}
);



/*
 * We need to modify Gnusto runner to get the final formatting of the status line.
 * Since Parchment loads some library files asynchronously we'll have to wait until
 * the runner.js file is loaded. When we reach the TextOutput function for the first
 * time we the file has been loaded and the first status line has not yet been printed.
 * 
 * As far as I can tell Console.renderHtml is called only when building the status line,
 * so we can safely (?) set the window to 1 (status line) when sending this text to
 * the transcript recorder. 
 * 
 * (There must be a better way to do this, but this works so it'll have to suffice.)
 */

var firstTextOutputHandler = function( data ) {
	Console.prototype.renderHtml = function() {
    var string = "";
    var currString = "";
    for (var y = 0; y < this.height; y++) {
      var currStyle = null;
      for (var x = 0; x < this.width; x++) {
        if (this._styles[y][x] !== currStyle) {
          if (currStyle !== null) {
  			ifRecorder.send( 1, currStyle, currString.replace( /\&nbsp\;/gi, ' ') );
			currString = '';
            string += "</span>";
          }
          currStyle = this._styles[y][x];
          if (currStyle !== null) {
            string += '<span class="' + currStyle + '">';
          }
        }
        string += this._characters[y][x];
        currString += this._characters[y][x];
      }
      if (currStyle !== null) {
        string += "</span>";
		ifRecorder.send( 1, currStyle, currString.replace( /\&nbsp\;/gi, ' ' )+"\n" );
		currString = '';
      }
      string += "<br/>";
    }
    return string;
  };
  
	// remove the handler, no need to run more than once
	$( document ).unbind( 'TextOutput', firstTextOutputHandler );
};

$( document ).bind( 'TextOutput', firstTextOutputHandler );

}(jQuery));



/* source: http://jquery-howto.blogspot.com/2009/09/get-url-parameters-values-with-jquery.html */
function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}
