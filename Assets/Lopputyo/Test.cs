using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace Lopputyo
{
    public class Test : MonoBehaviour
    {
        private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
        private static readonly int CellColor = Shader.PropertyToID("CellColour");
        private static readonly int State1Tex = Shader.PropertyToID("State1");
        private static readonly int State2Tex = Shader.PropertyToID("State2");
        
        [SerializeField] private Color cellColor;
        [SerializeField] private Seeds seed = Seeds.FullTexture;
        [SerializeField] private ComputeShader lifeSimulator;
        [SerializeField] private Material planeMaterial;
        [SerializeField, Range(0f, 2f)] private float updateInterval;

        private float _nextUpdate;
        private bool _isState1 = true;
        private static int  _updateKernel1, _updateKernel2, _fullKernel, _rPentominoKernel, _acornKernel, _gunKernel;
        private RenderTexture _state1, _state2;
        
        private static readonly Vector2Int TexSize = new Vector2Int(512, 512);

        void Start()
        {
            _updateKernel1 = lifeSimulator.FindKernel("Update1");
            _updateKernel2 = lifeSimulator.FindKernel("Update2");
            _fullKernel = lifeSimulator.FindKernel("InitFullTexture");
            _rPentominoKernel = lifeSimulator.FindKernel("InitRPentomino");
            _acornKernel = lifeSimulator.FindKernel("InitAcorn");
            _gunKernel = lifeSimulator.FindKernel("InitGun");
            
            _state1 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
            {
                filterMode = FilterMode.Point,
                enableRandomWrite = true
            }; _state1.Create();
            _state2 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
            {
                filterMode = FilterMode.Point,
                enableRandomWrite = true
            }; _state2.Create();
            
            lifeSimulator.SetTexture(_updateKernel1, State1Tex, _state1);
            lifeSimulator.SetTexture(_updateKernel1, State2Tex, _state2);
            lifeSimulator.SetTexture(_updateKernel2, State1Tex, _state1);
            lifeSimulator.SetTexture(_updateKernel2, State2Tex, _state2);
            
            lifeSimulator.SetTexture(_fullKernel, State2Tex, _state2);
            lifeSimulator.SetTexture(_rPentominoKernel, State2Tex, _state2);
            lifeSimulator.SetTexture(_acornKernel, State2Tex, _state2);
            lifeSimulator.SetTexture(_gunKernel, State2Tex, _state2);
            
            lifeSimulator.SetVector(CellColor, cellColor);
            
            switch(seed)
            {
                case Seeds.FullTexture:
                    lifeSimulator.Dispatch(_fullKernel, TexSize.x / 8, TexSize.y / 8, 1);
                    break;
                case Seeds.RPentomino:
                    lifeSimulator.Dispatch(_rPentominoKernel, TexSize.x / 8, TexSize.y / 8, 1);
                    break;
                case Seeds.Acorn:
                    lifeSimulator.Dispatch(_acornKernel, TexSize.x / 8, TexSize.y / 8, 1);
                    break;
                case Seeds.GosperGun:
                    lifeSimulator.Dispatch(_gunKernel, TexSize.x / 8, TexSize.y / 8, 1);
                    break;
            }
        }

        void Update()
        {
        
            if (Time.time < _nextUpdate) return;
        
            lifeSimulator.Dispatch(_isState1 ? _updateKernel1 : _updateKernel2, TexSize.x / 8, TexSize.y / 8, 1);
            planeMaterial.SetTexture(BaseMap, _isState1 ? _state1 : _state2);
            
            _nextUpdate = Time.time + updateInterval;
            _isState1 = !_isState1;
        }
        
        private void OnDisable()
        {
            _state1.Release();
            _state2.Release();
        }
        private void OnDestroy()
        {
            _state1.Release();
            _state2.Release();
        }
    }
}