import React, { useEffect, useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { ChevronDown, Info, Loader2, Play, Search, Volume2, X } from 'lucide-react';
import './styles.css';

const CATALOG_API_URL = import.meta.env.VITE_CATALOG_API_URL ?? '';
const PLAYBACK_API_URL = import.meta.env.VITE_PLAYBACK_API_URL ?? '';

const artwork = {
  'drama-001': {
    backdrop:
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1800&q=85',
    poster:
      'https://images.unsplash.com/photo-1518709268805-4e9042af2176?auto=format&fit=crop&w=900&q=85',
    maturity: '15+',
    year: '2024',
    match: '97%',
  },
  'drama-002': {
    backdrop:
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1800&q=85',
    poster:
      'https://images.unsplash.com/photo-1541544181051-e46607bc22a4?auto=format&fit=crop&w=900&q=85',
    maturity: '12+',
    year: '2024',
    match: '93%',
  },
  'drama-003': {
    backdrop:
      'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1800&q=85',
    poster:
      'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=900&q=85',
    maturity: '18+',
    year: '2025',
    match: '99%',
  },
};

const fallbackArt = artwork['drama-003'];

const fallbackDramas = [
  {
    id: 'drama-001',
    title: 'Signal Tree',
    genre: 'Mystery',
    description: '시간을 가로지르는 흔적을 따라 오래된 사건을 다시 여는 미스터리 시리즈.',
    releaseDate: '2024-03-12',
  },
  {
    id: 'drama-002',
    title: 'Northwind Diner',
    genre: 'Slice of Life',
    description: '작은 식당에 모인 이웃들의 밤과 오래 묻어둔 이야기가 천천히 겹쳐진다.',
    releaseDate: '2024-08-21',
  },
  {
    id: 'drama-003',
    title: 'Midnight Deploy',
    genre: 'Tech Thriller',
    description: '라이브 피날레 직전, 장애를 막기 위해 달리는 엔지니어들의 테크 스릴러.',
    releaseDate: '2025-01-09',
  },
];

const fallbackEpisodes = {
  'drama-001': [
    { id: 'episode-001-01', dramaId: 'drama-001', episodeNumber: 1, title: 'The First Signal', durationSeconds: 3510 },
    { id: 'episode-001-02', dramaId: 'drama-001', episodeNumber: 2, title: 'Cold Case Echo', durationSeconds: 3480 },
    { id: 'episode-001-03', dramaId: 'drama-001', episodeNumber: 3, title: 'Crossed Timeline', durationSeconds: 3620 },
  ],
  'drama-002': [
    { id: 'episode-002-01', dramaId: 'drama-002', episodeNumber: 1, title: 'Opening Shift', durationSeconds: 2890 },
    { id: 'episode-002-02', dramaId: 'drama-002', episodeNumber: 2, title: 'Soup Before Sunrise', durationSeconds: 2940 },
  ],
  'drama-003': [
    { id: 'episode-003-01', dramaId: 'drama-003', episodeNumber: 1, title: 'Incident Bridge', durationSeconds: 3120 },
    { id: 'episode-003-02', dramaId: 'drama-003', episodeNumber: 2, title: 'Rollback Window', durationSeconds: 3180 },
  ],
};

function App() {
  const [dramas, setDramas] = useState([]);
  const [selectedDramaId, setSelectedDramaId] = useState(null);
  const [dramaDetail, setDramaDetail] = useState(null);
  const [player, setPlayer] = useState(null);
  const [loading, setLoading] = useState({ dramas: false, detail: false, playback: false });
  const [error, setError] = useState('');

  const selectedDrama = useMemo(
    () => dramaDetail ?? dramas.find((drama) => drama.id === selectedDramaId) ?? dramas[0],
    [dramaDetail, dramas, selectedDramaId],
  );

  const heroArt = artwork[selectedDrama?.id] ?? fallbackArt;
  const continueEpisodes = dramaDetail?.episodes ?? fallbackEpisodes[selectedDrama?.id] ?? [];

  useEffect(() => {
    loadDramas();
  }, []);

  useEffect(() => {
    if (selectedDramaId) {
      loadDramaDetail(selectedDramaId);
    }
  }, [selectedDramaId]);

  async function requestJson(url) {
    const response = await fetch(url);
    const contentType = response.headers.get('content-type') ?? '';
    const payload = contentType.includes('application/json') ? await response.json() : await response.text();

    if (!response.ok) {
      const message =
        typeof payload === 'string'
          ? payload || response.statusText || `HTTP ${response.status}`
          : payload.detail ?? response.statusText ?? `HTTP ${response.status}`;
      throw new Error(message);
    }

    return payload;
  }

  async function loadDramas() {
    setError('');
    setLoading((state) => ({ ...state, dramas: true }));

    try {
      const data = await requestJson(`${CATALOG_API_URL}/api/catalog/dramas`);
      setDramas(data);
      setSelectedDramaId((current) => current ?? data[0]?.id ?? null);
    } catch (exception) {
      setDramas(fallbackDramas);
      setSelectedDramaId((current) => current ?? fallbackDramas[0].id);
      setError(`백엔드 연결 전이라 샘플 콘텐츠를 표시합니다. ${exception.message}`);
    } finally {
      setLoading((state) => ({ ...state, dramas: false }));
    }
  }

  async function loadDramaDetail(dramaId) {
    setError('');
    setLoading((state) => ({ ...state, detail: true }));

    try {
      const data = await requestJson(`${CATALOG_API_URL}/api/catalog/dramas/${dramaId}`);
      setDramaDetail(data);
    } catch (exception) {
      const fallbackDrama = fallbackDramas.find((drama) => drama.id === dramaId);
      setDramaDetail(
        fallbackDrama
          ? {
              ...fallbackDrama,
              episodes: fallbackEpisodes[dramaId] ?? [],
            }
          : null,
      );
      setError(`백엔드 상세 조회 전이라 샘플 회차를 표시합니다. ${exception.message}`);
    } finally {
      setLoading((state) => ({ ...state, detail: false }));
    }
  }

  async function openPlayer(episode) {
    if (!episode) {
      return;
    }

    setError('');
    setLoading((state) => ({ ...state, playback: true }));

    try {
      const playback = await requestJson(`${PLAYBACK_API_URL}/api/playback/${episode.id}`);
      setPlayer({ episode, playback });
    } catch (exception) {
      setPlayer({
        episode,
        playback: {
          episodeId: episode.id,
          streamUrl: `https://stream.daenamu.local/${episode.dramaId}/${episode.id}.m3u8`,
          status: 'PREVIEW',
        },
      });
      setError(`백엔드 재생 정보 전이라 미리보기 플레이어를 엽니다. ${exception.message}`);
    } finally {
      setLoading((state) => ({ ...state, playback: false }));
    }
  }

  return (
    <main className="app">
      <header className="nav">
        <div className="nav-left">
          <div className="logo">DAENAMU</div>
          <a>홈</a>
          <a>시리즈</a>
          <a>영화</a>
          <a>NEW</a>
          <a>내가 찜한 리스트</a>
        </div>
        <div className="nav-right">
          <Search size={20} />
          <span>KIDS</span>
          <div className="profile">D</div>
          <ChevronDown size={18} />
        </div>
      </header>

      <section
        className="hero"
        style={{
          '--hero-backdrop': `url(${heroArt.backdrop})`,
        }}
      >
        <div className="hero-copy">
          <p className="series-label">N SERIES</p>
          <h1>{selectedDrama?.title ?? 'DAENAMU'}</h1>
          <p className="meta">
            <strong>{heroArt.match} 일치</strong>
            <span>{heroArt.year}</span>
            <span className="maturity">{heroArt.maturity}</span>
            <span>{selectedDrama?.genre ?? 'Drama'}</span>
          </p>
          <p className="description">
            {dramaDetail?.description ??
              'DAENAMU 오리지널 시리즈를 선택하고 회차를 재생해보세요.'}
          </p>
          <div className="hero-actions">
            <button className="play-button" onClick={() => openPlayer(continueEpisodes[0])}>
              {loading.playback ? <Loader2 className="spin" size={24} /> : <Play size={24} fill="currentColor" />}
              재생
            </button>
            <button className="more-button" onClick={() => selectedDramaId && loadDramaDetail(selectedDramaId)}>
              <Info size={24} />
              상세 정보
            </button>
          </div>
        </div>
        <button className="mute-button" aria-label="음소거">
          <Volume2 size={20} />
        </button>
      </section>

      <section className="shelf-wrap">
        {error && <div className="notice">{error}</div>}

        <ContentShelf
          title="지금 뜨는 콘텐츠"
          items={dramas}
          selectedDramaId={selectedDramaId}
          onSelect={(drama) => setSelectedDramaId(drama.id)}
        />

        <EpisodeShelf
          title={selectedDrama ? `${selectedDrama.title} 회차` : '회차'}
          episodes={continueEpisodes}
          onPlay={openPlayer}
          isLoading={loading.detail}
        />

        <ContentShelf
          title="DAENAMU 추천작"
          items={[...dramas].reverse()}
          selectedDramaId={selectedDramaId}
          onSelect={(drama) => setSelectedDramaId(drama.id)}
        />
      </section>

      {player && (
        <PlayerOverlay
          drama={selectedDrama}
          episode={player.episode}
          playback={player.playback}
          onClose={() => setPlayer(null)}
        />
      )}
    </main>
  );
}

function ContentShelf({ title, items, selectedDramaId, onSelect }) {
  return (
    <section className="shelf">
      <h2>{title}</h2>
      <div className="card-row">
        {items.map((drama) => {
          const art = artwork[drama.id] ?? fallbackArt;

          return (
            <button
              className={`title-card ${selectedDramaId === drama.id ? 'selected' : ''}`}
              key={drama.id}
              onClick={() => onSelect(drama)}
            >
              <img src={art.poster} alt="" />
              <div className="title-card-overlay">
                <strong>{drama.title}</strong>
                <span>{drama.genre}</span>
              </div>
            </button>
          );
        })}
      </div>
    </section>
  );
}

function EpisodeShelf({ title, episodes, onPlay, isLoading }) {
  return (
    <section className="shelf">
      <h2>
        {title}
        {isLoading && <Loader2 className="spin inline-loader" size={18} />}
      </h2>
      <div className="episode-row">
        {episodes.map((episode) => (
          <button className="episode-card" key={episode.id} onClick={() => onPlay(episode)}>
            <div className="episode-thumb">
              <Play size={30} fill="currentColor" />
            </div>
            <div className="episode-copy">
              <span>에피소드 {episode.episodeNumber}</span>
              <strong>{episode.title}</strong>
              <small>{Math.round(episode.durationSeconds / 60)}분</small>
            </div>
          </button>
        ))}
      </div>
    </section>
  );
}

function PlayerOverlay({ drama, episode, playback, onClose }) {
  const art = artwork[drama?.id] ?? fallbackArt;

  return (
    <div className="player-backdrop">
      <section className="player">
        <button className="close-button" onClick={onClose} aria-label="닫기">
          <X size={24} />
        </button>
        <div className="video-frame" style={{ '--player-backdrop': `url(${art.backdrop})` }}>
          <div className="video-shade">
            <div className="big-play">
              <Play size={46} fill="currentColor" />
            </div>
            <p>재생 준비 완료</p>
          </div>
        </div>
        <div className="player-info">
          <div>
            <p className="series-label">N SERIES</p>
            <h2>{drama?.title}</h2>
            <p>
              에피소드 {episode.episodeNumber}. {episode.title}
            </p>
          </div>
          <div className="stream-box">
            <span>{playback.status}</span>
            <strong>{playback.episodeId}</strong>
            <small>{playback.streamUrl}</small>
          </div>
        </div>
      </section>
    </div>
  );
}

createRoot(document.getElementById('root')).render(<App />);
