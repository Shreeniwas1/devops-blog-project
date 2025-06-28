import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link, useParams } from 'react-router-dom';
import styled from 'styled-components';
import axios from 'axios';
import ReactMarkdown from 'react-markdown';
import './App.css';

const Container = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
`;

const Header = styled.header`
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 2rem 0;
  margin-bottom: 2rem;
  border-radius: 10px;
  text-align: center;
`;

const Nav = styled.nav`
  display: flex;
  justify-content: center;
  gap: 2rem;
  margin-bottom: 2rem;
  
  a {
    color: #667eea;
    text-decoration: none;
    font-weight: 500;
    padding: 0.5rem 1rem;
    border-radius: 5px;
    transition: background-color 0.3s;
    
    &:hover {
      background-color: #f0f0f0;
    }
  }
`;

const BlogCard = styled.div`
  background: white;
  border-radius: 10px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease;
  
  &:hover {
    transform: translateY(-5px);
  }
`;

const BlogTitle = styled.h2`
  color: #333;
  margin-bottom: 0.5rem;
`;

const BlogMeta = styled.div`
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 1rem;
`;

const BlogExcerpt = styled.p`
  color: #555;
  line-height: 1.6;
`;

const LoadingSpinner = styled.div`
  text-align: center;
  padding: 2rem;
  color: #667eea;
`;

const ErrorMessage = styled.div`
  background: #ffe6e6;
  color: #d00;
  padding: 1rem;
  border-radius: 5px;
  margin: 1rem 0;
`;

function App() {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchPosts();
  }, []);

  const fetchPosts = async () => {
    try {
      const apiUrl = process.env.REACT_APP_API_URL || 'http://localhost:3001';
      const response = await axios.get(`${apiUrl}/api/posts`);
      console.log('API Response:', response.data); // Debug log
      const postsData = response.data.posts || [];
      setPosts(Array.isArray(postsData) ? postsData : []);
      setLoading(false);
    } catch (err) {
      console.error('Error fetching posts:', err);
      setError('Failed to load blog posts. Please try again later.');
      setPosts([]); // Ensure posts remains an array
      setLoading(false);
    }
  };

  const Home = () => (
    <div>
      <Header>
        <h1>DevOps Personal Blog</h1>
        <p>Sharing knowledge about DevOps, Kubernetes, Docker, and CI/CD</p>
      </Header>
      
      {loading && <LoadingSpinner>Loading posts...</LoadingSpinner>}
      {error && <ErrorMessage>{error}</ErrorMessage>}
      
      {!loading && !error && (!posts || posts.length === 0) && (
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <p>No blog posts available at the moment.</p>
        </div>
      )}
      
      {Array.isArray(posts) && posts.length > 0 && posts.map((post) => (
        <BlogCard key={post.id}>
          <BlogTitle>{post.title}</BlogTitle>
          <BlogMeta>
            Published on {new Date(post.created_at).toLocaleDateString()} | 
            Tags: {post.tags || 'DevOps, Tutorial'}
          </BlogMeta>
          <BlogExcerpt>{post.excerpt || post.content.substring(0, 200) + '...'}</BlogExcerpt>
          <Link to={`/post/${post.id}`} style={{ color: '#667eea', textDecoration: 'none' }}>
            Read more →
          </Link>
        </BlogCard>
      ))}
    </div>
  );

  const About = () => (
    <div>
      <Header>
        <h1>About This Blog</h1>
      </Header>
      <BlogCard>
        <h2>Welcome to My DevOps Journey</h2>
        <p>
          This blog is a comprehensive DevOps project showcasing modern development and deployment practices.
          It demonstrates the use of various technologies and tools in a real-world scenario.
        </p>
        <h3>Technologies Used:</h3>
        <ul>
          <li><strong>Frontend:</strong> React.js with styled-components</li>
          <li><strong>Backend:</strong> Node.js with Express.js</li>
          <li><strong>Database:</strong> PostgreSQL</li>
          <li><strong>Containerization:</strong> Docker</li>
          <li><strong>Orchestration:</strong> Kubernetes</li>
          <li><strong>CI/CD:</strong> Jenkins</li>
          <li><strong>Monitoring:</strong> Prometheus & Grafana</li>
          <li><strong>Networking:</strong> Cloudflare Tunnel</li>
        </ul>
        <h3>DevOps Practices Demonstrated:</h3>
        <ul>
          <li>Infrastructure as Code (IaC)</li>
          <li>Containerized Applications</li>
          <li>Microservices Architecture</li>
          <li>Automated CI/CD Pipelines</li>
          <li>Monitoring and Observability</li>
          <li>Security Best Practices</li>
        </ul>
      </BlogCard>
    </div>
  );

  const PostDetail = () => {
    const { id: postId } = useParams();
    const [post, setPost] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
      const fetchPost = async () => {
        try {
          if (!postId) {
            setError('No post ID provided');
            setLoading(false);
            return;
          }
          
          const apiUrl = process.env.REACT_APP_API_URL || 'http://localhost:3001';
          console.log('Fetching post with ID:', postId); // Debug log
          const response = await axios.get(`${apiUrl}/api/posts/${postId}`);
          setPost(response.data);
          setError(null);
          setLoading(false);
        } catch (err) {
          console.error('Error fetching post:', err);
          setError('Failed to load post data');
          setLoading(false);
        }
      };
      fetchPost();
    }, [postId]);

    if (loading) return <LoadingSpinner>Loading post...</LoadingSpinner>;
    if (error) return <ErrorMessage>{error}</ErrorMessage>;
    if (!post) return <ErrorMessage>Post not found</ErrorMessage>;

    return (
      <div>
        <Header>
          <h1>{post.title}</h1>
          <p>Published on {new Date(post.created_at).toLocaleDateString()}</p>
        </Header>
        <BlogCard>
          <ReactMarkdown>{post.content}</ReactMarkdown>
        </BlogCard>
      </div>
    );
  };

  return (
    <Router>
      <Container>
        <Nav>
          <Link to="/">Home</Link>
          <Link to="/about">About</Link>
        </Nav>
        
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/post/:id" element={<PostDetail />} />
        </Routes>
      </Container>
    </Router>
  );
}

export default App;
