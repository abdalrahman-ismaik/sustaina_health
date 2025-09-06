# 🎨 Professional Diagram Templates for Sustaina Health

## 📊 Draw.io / Diagrams.net Templates

### 1. **Main Architecture Diagram (Draw.io XML)**

```xml
<mxGraphModel dx="1422" dy="794" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1169" pageHeight="827">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    
    <!-- User Layer -->
    <mxCell id="user" value="👤 User" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFE6CC;strokeColor=#D79B00;" vertex="1" parent="1">
      <mxGeometry x="40" y="200" width="120" height="60" as="geometry" />
    </mxCell>
    
    <!-- Flutter App -->
    <mxCell id="flutter_app" value="📱 Sustaina Health App" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#D5E8D4;strokeColor=#82B366;" vertex="1" parent="1">
      <mxGeometry x="240" y="80" width="280" height="300" as="geometry" />
    </mxCell>
    
    <!-- Core Features -->
    <mxCell id="home" value="🏠 Home Dashboard" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;" vertex="1" parent="1">
      <mxGeometry x="260" y="110" width="100" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="mcp_chat" value="💬 MCP Chat" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;" vertex="1" parent="1">
      <mxGeometry x="380" y="110" width="100" height="40" as="geometry" />
    </mxCell>
    
    <!-- Health Features -->
    <mxCell id="auth" value="🔐 Auth" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="260" y="170" width="60" height="30" as="geometry" />
    </mxCell>
    
    <mxCell id="exercise" value="💪 Exercise" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="330" y="170" width="60" height="30" as="geometry" />
    </mxCell>
    
    <mxCell id="nutrition" value="🍎 Nutrition" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="400" y="170" width="60" height="30" as="geometry" />
    </mxCell>
    
    <mxCell id="sleep" value="😴 Sleep" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="260" y="210" width="60" height="30" as="geometry" />
    </mxCell>
    
    <mxCell id="profile" value="👤 Profile" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="330" y="210" width="60" height="30" as="geometry" />
    </mxCell>
    
    <!-- App Infrastructure -->
    <mxCell id="riverpod" value="🔧 Riverpod" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#F8CECC;strokeColor=#B85450;" vertex="1" parent="1">
      <mxGeometry x="260" y="260" width="70" height="30" as="geometry" />
    </mxCell>
    
    <mxCell id="router" value="🧭 GoRouter" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#F8CECC;strokeColor=#B85450;" vertex="1" parent="1">
      <mxGeometry x="340" y="260" width="70" height="30" as="geometry" />
    </mxCell>
    
    <mxCell id="storage" value="💾 Storage" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#F8CECC;strokeColor=#B85450;" vertex="1" parent="1">
      <mxGeometry x="420" y="260" width="70" height="30" as="geometry" />
    </mxCell>
    
    <!-- Backend Services -->
    <mxCell id="backend" value="☁️ Backend Services" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;" vertex="1" parent="1">
      <mxGeometry x="600" y="80" width="280" height="300" as="geometry" />
    </mxCell>
    
    <!-- AI Services -->
    <mxCell id="fastapi" value="⚡ FastAPI" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;" vertex="1" parent="1">
      <mxGeometry x="620" y="110" width="80" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="mcp_server" value="🧠 MCP Server" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;" vertex="1" parent="1">
      <mxGeometry x="710" y="110" width="80" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="ai_workout" value="💪 Workout AI" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;" vertex="1" parent="1">
      <mxGeometry x="800" y="110" width="70" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="ai_nutrition" value="🍎 Nutrition AI" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;" vertex="1" parent="1">
      <mxGeometry x="620" y="160" width="80" height="40" as="geometry" />
    </mxCell>
    
    <!-- Firebase Services -->
    <mxCell id="firebase_auth" value="🔐 Firebase Auth" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="620" y="220" width="90" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="firestore" value="📄 Firestore" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="720" y="220" width="80" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="firebase_storage" value="📁 Firebase Storage" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="810" y="220" width="90" height="40" as="geometry" />
    </mxCell>
    
    <!-- Connections -->
    <mxCell id="conn1" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1" source="user" target="flutter_app">
      <mxGeometry width="50" height="50" relative="1" as="geometry">
        <mxPoint x="400" y="350" as="sourcePoint" />
        <mxPoint x="450" y="300" as="targetPoint" />
      </mxGeometry>
    </mxCell>
    
    <mxCell id="conn2" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1" source="flutter_app" target="backend">
      <mxGeometry width="50" height="50" relative="1" as="geometry">
        <mxPoint x="400" y="350" as="sourcePoint" />
        <mxPoint x="450" y="300" as="targetPoint" />
      </mxGeometry>
    </mxCell>
    
    <mxCell id="conn3" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1" source="mcp_chat" target="mcp_server">
      <mxGeometry width="50" height="50" relative="1" as="geometry">
        <mxPoint x="400" y="350" as="sourcePoint" />
        <mxPoint x="450" y="300" as="targetPoint" />
      </mxGeometry>
    </mxCell>
    
  </root>
</mxGraphModel>
```

### 2. **Sequence Diagram Template**

```xml
<mxGraphModel dx="1422" dy="794" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1169" pageHeight="827">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    
    <!-- Actors -->
    <mxCell id="user_actor" value="👤 User" style="shape=umlActor;verticalLabelPosition=bottom;verticalAlign=top;html=1;fillColor=#FFE6CC;strokeColor=#D79B00;" vertex="1" parent="1">
      <mxGeometry x="80" y="80" width="30" height="60" as="geometry" />
    </mxCell>
    
    <mxCell id="ui_actor" value="📱 Flutter UI" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#D5E8D4;strokeColor=#82B366;" vertex="1" parent="1">
      <mxGeometry x="200" y="90" width="80" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="chat_actor" value="💬 MCP Chat" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;" vertex="1" parent="1">
      <mxGeometry x="320" y="90" width="80" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="speech_actor" value="🎤 Speech-to-Text" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="440" y="90" width="90" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="mcp_actor" value="🧠 MCP Server" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;" vertex="1" parent="1">
      <mxGeometry x="560" y="90" width="80" height="40" as="geometry" />
    </mxCell>
    
    <mxCell id="ai_actor" value="🤖 AI Models" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#F8CECC;strokeColor=#B85450;" vertex="1" parent="1">
      <mxGeometry x="680" y="90" width="80" height="40" as="geometry" />
    </mxCell>
    
    <!-- Lifelines -->
    <mxCell id="user_lifeline" value="" style="endArrow=none;dashed=1;html=1;rounded=0;" edge="1" parent="1">
      <mxGeometry width="50" height="50" relative="1" as="geometry">
        <mxPoint x="95" y="150" as="sourcePoint" />
        <mxPoint x="95" y="600" as="targetPoint" />
      </mxGeometry>
    </mxCell>
    
    <mxCell id="ui_lifeline" value="" style="endArrow=none;dashed=1;html=1;rounded=0;" edge="1" parent="1">
      <mxGeometry width="50" height="50" relative="1" as="geometry">
        <mxPoint x="240" y="150" as="sourcePoint" />
        <mxPoint x="240" y="600" as="targetPoint" />
      </mxGeometry>
    </mxCell>
    
    <!-- Messages -->
    <mxCell id="msg1" value="Opens Home Dashboard" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1">
      <mxGeometry width="50" height="50" relative="1" as="geometry">
        <mxPoint x="95" y="180" as="sourcePoint" />
        <mxPoint x="240" y="180" as="targetPoint" />
      </mxGeometry>
    </mxCell>
    
    <mxCell id="msg2" value="Display MCP Chat FAB" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1">
      <mxGeometry width="50" height="50" relative="1" as="geometry">
        <mxPoint x="240" y="210" as="sourcePoint" />
        <mxPoint x="360" y="210" as="targetPoint" />
      </mxGeometry>
    </mxCell>
    
    <mxCell id="msg3" value="Press & Hold Microphone" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1">
      <mxGeometry width="50" height="50" relative="1" as="geometry">
        <mxPoint x="95" y="240" as="sourcePoint" />
        <mxPoint x="360" y="240" as="targetPoint" />
      </mxGeometry>
    </mxCell>
    
  </root>
</mxGraphModel>
```

---

## 🖼️ Mermaid to Image Export Instructions

### Method 1: **Using Mermaid Live Editor**

1. **Go to**: [mermaid.live](https://mermaid.live)
2. **Paste** any of the Mermaid diagrams from the improvement document
3. **Export** as PNG, SVG, or PDF
4. **Download** high-quality images for presentations

### Method 2: **Using VS Code Mermaid Extension**

1. **Install**: Mermaid Preview extension in VS Code
2. **Create** `.md` file with Mermaid code blocks
3. **Right-click** on preview → "Export to Image"
4. **Save** as PNG or SVG

### Method 3: **Using Mermaid CLI**

```bash
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Export diagram to PNG
mmdc -i diagram.mmd -o diagram.png

# Export with custom theme
mmdc -i diagram.mmd -o diagram.png -t dark
```

---

## 📊 Ready-to-Use Diagram Files

Let me create specific files you can immediately import into Draw.io:
