part of dart_gl;


// textures to load
const texturesToLoad = const {
    "wall"     : "brick.png",
    "font"     : "font.png",
    "frame1"   : "frame1.png",
    "atlasTex" : "atlas.png"
};


/*
 * Basic texture
 */
class Texture
{
    Texture(this.glTexture, this.width, this.height);

    final WebGL.Texture glTexture;
    final int width;
    final int height;

    void Bind()
    {
        glContext.bindTexture(WebGL.RenderingContext.TEXTURE_2D, glTexture);
    }
}


/*
 * Texture loader/binder
 */
class TextureManager
{
    int  numTexturesLoaded;
    bool allTexLoaded;
    Texture activeTexture;
    Map<String, Texture> textures;

    TextureManager()
    {
        textures = new Map<String, Texture>();
        numTexturesLoaded = 0;
        allTexLoaded   = false;

        texturesToLoad.forEach((name, fileName) => _loadTexture(name, fileName));
    }

    Texture bindTexture(String texName)
    {
        activeTexture = textures[texName];
        activeTexture.Bind();
        return activeTexture;
    }
    
    void _loadTexture(String texName, String fileName)
    {
        ImageElement image = new Element.tag('img');

        image.onLoad.listen((e) {
            textures[texName] = new Texture(glContext.createTexture(), image.width, image.height);

            texMgr.bindTexture(texName);
            //glContext.pixelStorei(WebGL.RenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
            glContext.texImage2DImage(WebGL.RenderingContext.TEXTURE_2D, 0, WebGL.RenderingContext.RGBA, WebGL.RenderingContext.RGBA, WebGL.RenderingContext.UNSIGNED_BYTE, image);
            glContext.texParameteri(WebGL.RenderingContext.TEXTURE_2D, WebGL.RenderingContext.TEXTURE_MAG_FILTER, WebGL.RenderingContext.NEAREST);
            glContext.texParameteri(WebGL.RenderingContext.TEXTURE_2D, WebGL.RenderingContext.TEXTURE_MIN_FILTER, WebGL.RenderingContext.NEAREST);

            //glContext.texParameteri(WebGL.RenderingContext.TEXTURE_2D, WebGL.RenderingContext.TEXTURE_MIN_FILTER, WebGL.RenderingContext.LINEAR);
            //glContext.texParameteri(WebGL.RenderingContext.TEXTURE_2D, WebGL.RenderingContext.TEXTURE_MAG_FILTER, WebGL.RenderingContext.LINEAR);      

            glContext.bindTexture(WebGL.RenderingContext.TEXTURE_2D, null);

            allTexLoaded = ++numTexturesLoaded == texturesToLoad.length;
        });

        image.src = fileName;
    }
}