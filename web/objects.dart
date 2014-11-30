part of dart_gl;

/*
 * Common renderable elements
 */
abstract class BaseRenderable
{
    int width;
    int height;
    Shader  shader;
    Texture texture;
    Vector3 position;
    Vector3 rotation;
    Vector2 pivot;
    Vector3 scale;
    bool    fixedPos;     // should the object remain at fixed position - regardless of the camera?
    Vector2 uvOffsets;    // texture offsets
    Matrix4 textureMatrix;
    WebGL.Buffer _indexBuffer;
    WebGL.Buffer _vertexBuffer;
    
    // shader locations
    int a_positionLocation;
    WebGL.UniformLocation u_textureMatrixLocation;
    WebGL.UniformLocation u_vertexColorLocation;

    BaseRenderable(this.shader, this.width, this.height, this.position, [this.pivot = null, this.uvOffsets = null])
    {
        a_positionLocation      = glContext.getAttribLocation(shader.program,  "a_position");
        u_textureMatrixLocation = glContext.getUniformLocation(shader.program, "u_textureMatrix");
        u_vertexColorLocation   = glContext.getUniformLocation(shader.program, "u_vertexColor");
        
        if(uvOffsets == null)
          uvOffsets = new Vector2(0.0, 0.0);
        
        fixedPos = false;

        Float32List vertexArray = new Float32List(4 * 3);
        vertexArray.setAll(0 * 3, [0.0, 0.0, 0.0]);
        vertexArray.setAll(1 * 3, [1.0, 0.0, 0.0]);
        vertexArray.setAll(2 * 3, [1.0, -1.0, 0.0]);
        vertexArray.setAll(3 * 3, [0.0, -1.0, 0.0]);

        Int16List indexArray = new Int16List(6);
        indexArray.setAll(0, [0, 1, 2, 0, 2, 3]);

        if(position == null)
            position = new Vector3(0.0, 0.0, 0.0);
        
        rotation = new Vector3(0.0, 0.0, 0.0);
        
        if(pivot == null)
            pivot = new Vector2(0.0, 0.0);
        
        scale = new Vector3(1.0, 1.0, 1.0);

        _indexBuffer = glContext.createBuffer();
        _vertexBuffer = glContext.createBuffer();
        textureMatrix = new Matrix4.identity();

        glContext.enableVertexAttribArray(a_positionLocation);

        _vertexBuffer = glContext.createBuffer();
        glContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, _vertexBuffer);
        glContext.bufferDataTyped(WebGL.RenderingContext.ARRAY_BUFFER, vertexArray, WebGL.STATIC_DRAW);
        glContext.vertexAttribPointer(a_positionLocation, 3, WebGL.FLOAT, false, 0, 0);

        _indexBuffer = glContext.createBuffer();
        glContext.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
        glContext.bufferDataTyped(WebGL.ELEMENT_ARRAY_BUFFER, indexArray, WebGL.STATIC_DRAW);
        glContext.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    }

    void OnNewFrame(double dt)
    {
        renderAt(position, width, height, uvOffsets.x, uvOffsets.y, new Vector4(1.0, 1.0, 1.0, 1.0));
    }

    void renderAt(Vector3 pos, int w, int h, num uo, num vo, Vector4 color);
}


/*
 *  Rectangular renderable - texture fills entire quad.
 */
class RectObject extends BaseRenderable
{
    RectObject(shader, [width = null, height = null, position = null, pivot = null]) : super(shader, width, height, position, pivot);
    RectObject.zeroSize(shader, [position = null, pivot = null]) : super(shader, 0, 0, position, pivot);

    void renderAt(Vector3 pos, int w, int h, num uo, num vo, Vector4 color)
    {
        if(texture == null)
            print("Trying to render with no texture?");

        shader.Load();
        texture.Bind();

        glContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, _vertexBuffer);
        glContext.vertexAttribPointer(a_positionLocation, 3, WebGL.RenderingContext.FLOAT, false, 0, 0);

        glContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, _indexBuffer);

        GL.PushMatrix();

        if(fixedPos)
            GL.LoadIdentity();

        GL.Translate(pos.x - 2 * pivot.x * w / canvas.height, pos.y + 2 * pivot.y * h / canvas.height, pos.z);
        GL.RotateXYZ(rotation.x, rotation.y, rotation.z);
        GL.Scale(2 * w / canvas.height, 2 * h / canvas.height);
        GL.Scale(scale.x, scale.y, scale.z);

        textureMatrix.setIdentity();
        glContext.uniformMatrix4fv(u_textureMatrixLocation, false, textureMatrix.storage);
        glContext.uniform4fv(u_vertexColorLocation, color.storage);

        glContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, _indexBuffer);
        glContext.drawElements(WebGL.TRIANGLES, 6, WebGL.UNSIGNED_SHORT, 0);

        GL.PopMatrix();
    }
}


/*
 *  Rectangular renderable - texture is a snippet from a bigger atlas 
 */
class RectClipObject extends BaseRenderable
{
    RectClipObject(shader, [width = null, height = null, position = null, uvOffsets = null, pivot = null]) : super(shader, width, height, position, pivot, uvOffsets);
    RectClipObject.zeroSize(shader, [position = null, uvOffsets = null, pivot = null ]) : super(shader, 0, 0, position, pivot, uvOffsets);

    void renderAt(Vector3 pos, int w, int h, num uo, num vo, Vector4 color)
    {
        if(texture == null)
            print("Trying to render with no texture?");

        shader.Load();
        texture.Bind();
        
        glContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, _vertexBuffer);
        glContext.vertexAttribPointer(a_positionLocation, 3, WebGL.RenderingContext.FLOAT, false, 0, 0);

        glContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, _indexBuffer);

        GL.PushMatrix();

        if(fixedPos)
            GL.LoadIdentity();

        GL.Translate(pos.x - 2 * pivot.x * width / canvas.height, pos.y + 2 * pivot.y * height / canvas.height, pos.z);
        GL.RotateXYZ(rotation.x, rotation.y, rotation.z);
        GL.Scale(2 * w / canvas.height, 2 * h / canvas.height);
        GL.Scale(scale.x, scale.y, scale.z);

        textureMatrix.setIdentity();   
        textureMatrix.scale(1.0 / texture.width, 1.0 / texture.height);
        textureMatrix.translate(uo*1.0, -vo*1.0);
        textureMatrix.scale(w*1.0, h*1.0);

        glContext.uniformMatrix4fv(u_textureMatrixLocation, false, textureMatrix.storage);
        glContext.uniform4fv(u_vertexColorLocation, color.storage);

        glContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, _indexBuffer);
        glContext.drawElements(WebGL.TRIANGLES, 6, WebGL.UNSIGNED_SHORT, 0);

        GL.PopMatrix();
    }
}


/*
 * Simple font
 */
class Font extends RectClipObject
{
    String _textureName;
    
    Font(shader, this._textureName, [position = null]) : super(shader, 0, 0, position, null, null);
    
    void drawText(String text, Vector4 color) 
    {
        int charWidth  = 6;
        int charHeight = 7;

        texture = texMgr.bindTexture(this._textureName);

        Vector3 pos = position.clone();

        pos.x /= charWidth;
        pos.y /= charHeight;

        for(int i = 0; i<text.length; i++) 
        {
            int cu = text.codeUnitAt(i) - 32;
            if (cu >= 0 && cu < 32 * 3) {
                renderAt(pos, charWidth, charHeight, cu % 16 * charWidth, cu~/ 16 * (charHeight + 1), color);
            }

            pos.x += 1.0 * (scale.x * 2 * charWidth / canvas.height);
        }
    }    
}
