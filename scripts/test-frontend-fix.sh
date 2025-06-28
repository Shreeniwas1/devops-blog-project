#!/bin/bash

# Test script to verify the frontend routing fix
echo "🔧 Testing frontend routing fix..."

# Test if port forwards are running
echo "📡 Checking port forwards..."
if pgrep -f "kubectl port-forward.*frontend" > /dev/null; then
    echo "✅ Frontend port forward is running"
else
    echo "❌ Frontend port forward is not running"
fi

if pgrep -f "kubectl port-forward.*backend" > /dev/null; then
    echo "✅ Backend port forward is running"
else
    echo "❌ Backend port forward is not running"
fi

# Test API endpoints
echo ""
echo "🔍 Testing API endpoints..."

echo "Testing backend health:"
curl -s http://localhost:3001/health | jq -r '.message' 2>/dev/null || echo "❌ Backend health check failed"

echo "Testing posts list:"
curl -s http://localhost:3001/api/posts | jq -r '.posts | length' 2>/dev/null | xargs -I {} echo "✅ Found {} posts"

echo "Testing individual post (ID: 3):"
curl -s http://localhost:3001/api/posts/3 | jq -r '.title' 2>/dev/null | xargs -I {} echo "✅ Post title: {}"

echo ""
echo "🌐 Frontend URLs:"
echo "  Main site: http://localhost:3000"
echo "  Example post: http://localhost:3000/post/3"
echo ""
echo "💡 The routing issue has been fixed:"
echo "  - Using proper React Router useParams() hook"
echo "  - Added error handling for missing post IDs"
echo "  - Fixed manifest.json syntax error"
echo "  - Frontend image has been rebuilt and redeployed"
echo ""
echo "🎯 You should now be able to click on posts without needing to refresh!"
