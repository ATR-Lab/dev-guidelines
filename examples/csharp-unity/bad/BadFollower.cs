// Deliberately bad C#: scripts/check-configs.sh expects dotnet build (with the lab .editorconfig and
// Microsoft.Unity.Analyzers) and dotnet format to reject this file. Do not copy it.
using System.Collections.Generic; // IDE0005 unnecessary using
using UnityEngine;

namespace Atr.Bad
{
    public class bad_follower : MonoBehaviour { // IDE1006 naming, IDE0055 brace on same line
        public Transform target;   // IDE1006: public fields are PascalCase
        private float speed = 1f;  // IDE1006: private fields are _camelCase

        void Update() // IDE0040: missing accessibility modifier
        {
        } // UNT0001: empty Unity message

        private void LateUpdate()
        {
            if (target?.position == null) return; // UNT0008: null propagation, IDE0011: braces
            if (target.gameObject is null) { } // UNT0029: pattern matching with null
        }
    }
}
