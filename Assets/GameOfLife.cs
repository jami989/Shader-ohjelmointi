using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.RenderGraphModule;
using UnityEngine.Rendering;

public enum Seeds
{
    FullTexture,
    R_Pentomino,
    Acorn,
    Gosper_Gun
}

public class GameOfLife : MonoBehaviour
{
    private static readonly int BaseMap = Shader.PropertyToID("BaseMap");
    private static readonly int CellColor = Shader.PropertyToID("CellColour");
    //private static readonly int TextureSize = Shader.PropertyToID("CellColour"); // bonus
    private static readonly int State1Tex = Shader.PropertyToID("State1");
    private static readonly int State2Tex = Shader.PropertyToID("State2");
    
    [SerializeField] private Color cellColor;
    
    [SerializeField] private Seeds seed = Seeds.FullTexture; // Dropdown menu
    
    
    
    
    [SerializeField] private ComputeShader LifeSimulator; // LifeSimulation.compute
    //[SerializeField] private Mesh LifeMesh;
    [SerializeField] private Material PlaneMaterial;

    private static int UpdateKernel1, UpdateKernel2;
    private RenderTexture state1, state2;
    
    [SerializeField, Range(0f, 2f)] private float UpdateInterval;
    private float NextUpdate;
    private bool isState1 = true;
    
    private static readonly Vector2Int TexSize = new Vector2Int(512, 512);
    
    void Start()
    {
        UpdateKernel1 = LifeSimulator.FindKernel("Update1");
        UpdateKernel2 = LifeSimulator.FindKernel("Update2");

        state1 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        }; state1.Create();
        state2 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        }; state2.Create();
        
        // Add everything that won't ever be updated to compute shaders
        LifeSimulator.SetTexture(UpdateKernel1, State1Tex, state1);
        LifeSimulator.SetTexture(UpdateKernel1, State2Tex, state2);
        
        LifeSimulator.SetTexture(UpdateKernel2, State1Tex, state1);
        LifeSimulator.SetTexture(UpdateKernel2, State2Tex, state2);
        
        LifeSimulator.SetTexture(LifeSimulator.FindKernel("InitFullTexture"), State1Tex, state1);
        LifeSimulator.SetTexture(LifeSimulator.FindKernel("InitRPentomino"), State1Tex, state1);
        LifeSimulator.SetTexture(LifeSimulator.FindKernel("InitAcorn"), State1Tex, state1);
        LifeSimulator.SetTexture(LifeSimulator.FindKernel("InitGun"), State1Tex, state1);
        
        LifeSimulator.SetVector(CellColor, cellColor);
        
        // bonus
        //LifeSimulator.SetVector(TextureSize, new vector2());
        
        // initialise simulation with seed
        switch(seed)
        {
            case Seeds.FullTexture:
                LifeSimulator.Dispatch(LifeSimulator.FindKernel("InitFullTexture"), TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case Seeds.R_Pentomino:
                LifeSimulator.Dispatch(LifeSimulator.FindKernel("InitRPentomino"), TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case Seeds.Acorn:
                LifeSimulator.Dispatch(LifeSimulator.FindKernel("InitAcorn"), TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case Seeds.Gosper_Gun:
                LifeSimulator.Dispatch(LifeSimulator.FindKernel("InitGun"), TexSize.x / 8, TexSize.y / 8, 1);
                break;
            default:
                break;
        }
    }

    void Update()
    {
        if (Time.time < NextUpdate) return;
        NextUpdate = Time.time + UpdateInterval;
        isState1 = !isState1;
        
        // Scriptin kuuluisi myös päivittää esitykseen käytetyn materiaalin
        // tekstuuria vaiheen mukaan (flipbook).
        LifeSimulator.Dispatch(isState1 ? UpdateKernel1 : UpdateKernel2, TexSize.x / 8, TexSize.y / 8, 1);
        PlaneMaterial.SetTexture(BaseMap, isState1 ? state1 : state2);
    }
    
    private void OnDisable()
    {
        state1.Release();
        state2.Release();
    }
    private void OnDestroy()
    {
        state1.Release();
        state2.Release();
    }
}
