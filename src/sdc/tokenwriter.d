/**
 * Copyright 2011 Jakob Bornecrantz.
 * Copyright 2010-2011 Bernard Helyer.
 * Copyright 2010 Jakob Ovrum.
 * This file is part of SDC. SDC is licensed under the GPL.
 * See LICENCE or sdc.d for more details.
 */ 
module sdc.tokenwriter;

import sdc.source;
import sdc.tokenstream;


/**
 * Small container class for tokens.
 */
class TokenWriter
{
    string filename;
    Source source;
    
    private Token[] mTokens;

    /**
     * Create a new TokenWriter and initialize
     * the first token to TokenType.Begin.
     */
    this(Source source)
    {
        filename = source.location.filename;
        this.source = source;
        initTokenArray();
    }
    
    void addToken(Token token)
    {
        mTokens ~= token;
        token.location.length = token.value.length;
    }
    
    Token lastAdded() @property
    {
        return mTokens[$ - 1];
    }

    /**
     * Create a TokenStream from this writer's tokens.
     *
     * TODO: Currently this function will leave the writer in a bit of a
     *       odd state. Since it resets the tokens but not the source.
     *
     * Side-effects:
     *   Remove all tokens from this writer, and reinitializes the writer.
     */
    TokenStream getStream()
    {
        auto tstream = new TokenStream(filename, mTokens);
        initTokenArray();
        return tstream;
    }

    private void initTokenArray()
    {
        auto start = new Token();
        start.type = TokenType.Begin;
        start.value = "START";

        // Reset the token array
        mTokens = [start];
    }
}
