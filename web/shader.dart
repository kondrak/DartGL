part of dart_gl;

/*
 * Shader definitions and management
 */
class ShaderManager
{
    Map<String, Shader> shaders;

    ShaderManager()
    {
        shaders = new Map<String, Shader>();

        shaders['basicShader'] = new BasicShader();
        shaders['renderColor'] = new RenderColorShader();
    }

    Shader Load(String shaderName)
    {
        Shader loadedShader = shaders[shaderName];
        loadedShader.Load();

        return loadedShader;
    }
}

abstract class Shader
{
    WebGL.Shader vertexShader;
    WebGL.Shader fragmentShader;

    final String vsSource;
    final String fsSource;

    WebGL.Program program;
  
    Shader(this.vsSource, this.fsSource)
    {      
        // vertex shader compilation
        vertexShader = glContext.createShader(WebGL.RenderingContext.VERTEX_SHADER);
        glContext.shaderSource(vertexShader, vsSource);
        glContext.compileShader(vertexShader);
        
        if(!glContext.getShaderParameter(vertexShader, WebGL.COMPILE_STATUS)) 
        {
            print(glContext.getShaderInfoLog(vertexShader));
            throw glContext.getShaderInfoLog(vertexShader);
        } 
        
        // fragment shader compilation
        fragmentShader = glContext.createShader(WebGL.RenderingContext.FRAGMENT_SHADER);
        glContext.shaderSource(fragmentShader, fsSource);
        glContext.compileShader(fragmentShader);
        
        if(!glContext.getShaderParameter(fragmentShader, WebGL.COMPILE_STATUS)) 
        {
            print(glContext.getShaderInfoLog(fragmentShader));
            throw glContext.getShaderInfoLog(fragmentShader);
        }        
        
        program = glContext.createProgram();
        
        // attach shaders to a WebGL program
        glContext.attachShader(program, vertexShader);
        glContext.attachShader(program, fragmentShader);
        glContext.linkProgram(program);  
        
        if(!glContext.getProgramParameter(program, WebGL.LINK_STATUS)) 
        {
            print(glContext.getProgramInfoLog(program));
            throw glContext.getProgramInfoLog(program);
        }        
    }
  
    void Load()
    {
        glContext.useProgram(program);  
        
        // tell camera to use proper matrix uniforms since we changed shader
        camDirector.activeCamera.u_pMatrixLocation  = glContext.getUniformLocation(program, "u_camPerspMatrix");
        camDirector.activeCamera.u_mvMatrixLocation = glContext.getUniformLocation(program, "u_camModelViewMatrix");
        camDirector.activeCamera.applyTransformations();       
    }   
}


class BasicShader extends Shader
{
    BasicShader() : super(vs, fs)
    {

    }

    static final String vs = """
    precision mediump float;
  
    attribute vec3 a_position;

    uniform mat4 u_camPerspMatrix;
    uniform mat4 u_camModelViewMatrix;
    uniform mat4 u_textureMatrix;
    uniform vec4 u_vertexColor;

    varying vec2 v_texCoord;
  
    void main() 
    {
      v_texCoord  = (u_textureMatrix * vec4(a_position, 1.0)).xy;
      gl_Position = u_camPerspMatrix * u_camModelViewMatrix * vec4(a_position, 1.0); 
    }
    """;  

    static final String fs = """
    precision mediump float;    

    uniform sampler2D u_tex;
    uniform vec4 u_vertexColor;

    varying vec2 v_texCoord;

    void main() {
      vec4 color = texture2D(u_tex, v_texCoord)* u_vertexColor;
      if(color.a > 0.0) 
      {
        gl_FragColor = color; 
      } 
      else 
      {
        discard;
      }
  }
    """; 
}


class RenderColorShader extends Shader
{
    RenderColorShader() : super(vs, fs)
    {

    }

    static final String vs = """
    attribute vec3 coordinates;
    attribute vec2 texCoords;
    attribute vec4 aVertexColor;

    uniform mat4 uPMatrix;
    uniform mat4 uMVMatrix;

    varying vec4 vColor;
    varying vec2 vTextureCoord;

    void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(coordinates, 1.0);
        vColor = aVertexColor;
        vTextureCoord = texCoords;
    }
    """;  

    static final String fs = """
    precision mediump float;

    varying vec4 vColor;

    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;

    void main(void) {
        gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t)) * vColor;
    }
    """; 
}