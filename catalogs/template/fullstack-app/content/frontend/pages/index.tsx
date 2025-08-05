import { useState, useEffect } from 'react';
import Head from 'next/head';
import axios from 'axios';

interface HealthStatus {
  status: string;
  timestamp: string;
  database: string;
  service: string;
}

interface ServiceStatus {
  service: string;
  status: string;
  recent_health_checks: number;
  last_check: string | null;
}

export default function Home() {
  const [health, setHealth] = useState<HealthStatus | null>(null);
  const [serviceStatus, setServiceStatus] = useState<ServiceStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        
        // Health check
        const healthResponse = await axios.get(`${API_BASE_URL}/health`);
        setHealth(healthResponse.data);
        
        // Service status
        const statusResponse = await axios.get(`${API_BASE_URL}/api/status`);
        setServiceStatus(statusResponse.data);
        
        setError(null);
      } catch (err) {
        console.error('API 호출 실패:', err);
        setError('백엔드 서버에 연결할 수 없습니다.');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [API_BASE_URL]);

  return (
    <>
      <Head>
        <title>${{ values.name | capitalize }} - Full Stack Application</title>
        <meta name="description" content="${{ values.description }}" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main style={{ 
        padding: '2rem', 
        fontFamily: 'system-ui, -apple-system, sans-serif',
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        color: 'white'
      }}>
        <div style={{
          maxWidth: '800px',
          margin: '0 auto',
          background: 'rgba(255, 255, 255, 0.1)',
          borderRadius: '20px',
          padding: '2rem',
          backdropFilter: 'blur(10px)',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)'
        }}>
          <h1 style={{ 
            fontSize: '3rem',
            marginBottom: '1rem',
            textAlign: 'center',
            background: 'linear-gradient(45deg, #fff, #e0e0e0)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            backgroundClip: 'text'
          }}>
            🚀 ${{ values.name | capitalize }}
          </h1>
          
          <p style={{ 
            fontSize: '1.2rem',
            textAlign: 'center',
            marginBottom: '2rem',
            opacity: 0.9
          }}>
            ${{ values.description }}
          </p>
          
          <div style={{ 
            marginBottom: '2rem',
            padding: '1.5rem',
            background: 'rgba(255, 255, 255, 0.1)',
            borderRadius: '15px',
            border: '1px solid rgba(255, 255, 255, 0.2)'
          }}>
            <h2 style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>📊</span> 시스템 상태
            </h2>
            
            {loading ? (
              <div style={{ textAlign: 'center', padding: '2rem' }}>
                <div style={{
                  display: 'inline-block',
                  width: '40px',
                  height: '40px',
                  border: '4px solid rgba(255, 255, 255, 0.3)',
                  borderTop: '4px solid white',
                  borderRadius: '50%',
                  animation: 'spin 1s linear infinite'
                }} />
                <p style={{ marginTop: '1rem' }}>로딩 중...</p>
                <style jsx>{`
                  @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                  }
                `}</style>
              </div>
            ) : error ? (
              <div style={{
                padding: '1rem',
                background: 'rgba(255, 0, 0, 0.2)',
                borderRadius: '10px',
                border: '1px solid rgba(255, 0, 0, 0.3)'
              }}>
                <p>❌ {error}</p>
                <p style={{ fontSize: '0.9rem', opacity: 0.8, marginTop: '0.5rem' }}>
                  백엔드 서비스가 아직 시작되지 않았거나 배포 중일 수 있습니다.
                </p>
              </div>
            ) : (
              <div style={{ display: 'grid', gap: '1rem' }}>
                {health && (
                  <div style={{
                    padding: '1rem',
                    background: 'rgba(0, 255, 0, 0.2)',
                    borderRadius: '10px',
                    border: '1px solid rgba(0, 255, 0, 0.3)'
                  }}>
                    <p><strong>✅ 상태:</strong> {health.status}</p>
                    <p><strong>🕒 시간:</strong> {new Date(health.timestamp).toLocaleString('ko-KR')}</p>
                    <p><strong>🗄️ 데이터베이스:</strong> {health.database}</p>
                    <p><strong>🔧 서비스:</strong> {health.service}</p>
                  </div>
                )}
                
                {serviceStatus && (
                  <div style={{
                    padding: '1rem',
                    background: 'rgba(0, 150, 255, 0.2)',
                    borderRadius: '10px',
                    border: '1px solid rgba(0, 150, 255, 0.3)'
                  }}>
                    <p><strong>📈 서비스 상태:</strong> {serviceStatus.status}</p>
                    <p><strong>🔍 헬스체크 횟수:</strong> {serviceStatus.recent_health_checks}</p>
                    {serviceStatus.last_check && (
                      <p><strong>🕐 마지막 체크:</strong> {new Date(serviceStatus.last_check).toLocaleString('ko-KR')}</p>
                    )}
                  </div>
                )}
              </div>
            )}
          </div>

          <div style={{ marginBottom: '2rem' }}>
            <h2 style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🛠️</span> 기술 스택
            </h2>
            <div style={{ 
              display: 'grid', 
              gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
              gap: '1rem' 
            }}>
              {[
                { icon: '⚛️', name: 'Next.js Frontend', desc: 'React 기반 프론트엔드' },
                { icon: '🐍', name: 'Python FastAPI', desc: '고성능 API 서버' },
                { icon: '🐘', name: 'PostgreSQL', desc: '관계형 데이터베이스' },
                { icon: '🐳', name: 'Docker', desc: '컨테이너화된 배포' },
                { icon: '☁️', name: 'AWS', desc: 'EC2, RDS, ALB' },
                { icon: '🚀', name: 'Bitbucket Pipeline', desc: 'CI/CD 자동화' }
              ].map((tech, index) => (
                <div key={index} style={{
                  padding: '1rem',
                  background: 'rgba(255, 255, 255, 0.1)',
                  borderRadius: '10px',
                  border: '1px solid rgba(255, 255, 255, 0.2)',
                  textAlign: 'center'
                }}>
                  <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>{tech.icon}</div>
                  <h3 style={{ fontSize: '1rem', marginBottom: '0.25rem' }}>{tech.name}</h3>
                  <p style={{ fontSize: '0.8rem', opacity: 0.8 }}>{tech.desc}</p>
                </div>
              ))}
            </div>
          </div>

          <div style={{
            textAlign: 'center',
            padding: '1rem',
            background: 'rgba(255, 255, 255, 0.1)',
            borderRadius: '10px',
            border: '1px solid rgba(255, 255, 255, 0.2)'
          }}>
            <p style={{ marginBottom: '1rem' }}>
              🎉 <strong>Backstage</strong>에서 생성된 풀스택 애플리케이션
            </p>
            <p style={{ fontSize: '0.9rem', opacity: 0.8 }}>
              AWS 리전: <strong>${{ values.awsRegion }}</strong> | 
              인스턴스: <strong>${{ values.instanceType }}</strong>
            </p>
          </div>
        </div>
      </main>
    </>
  );
}