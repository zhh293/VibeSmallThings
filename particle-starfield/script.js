// 全局变量
let scene, camera, renderer, particles, particleSystem;
let mouseX = 0, mouseY = 0;
let windowHalfX = window.innerWidth / 2;
let windowHalfY = window.innerHeight / 2;
let isStarfieldActive = false;

// 手部追踪变量
let hands;
let videoElement;
let canvasElement;
let canvasCtx;
let handDetected = false;
let useHandTracking = true; // 是否使用手部追踪（可切换为鼠标模式）

// 粒子配置
const PARTICLE_COUNT = 15000;
const PARTICLE_SIZE = 2;
const SPACE_SIZE = 2000;
const CONNECTION_DISTANCE = 80;

// 初始化场景
function initStarfield() {
    const canvas = document.getElementById('starfield');

    // 创建场景
    scene = new THREE.Scene();
    scene.fog = new THREE.FogExp2(0x030508, 0.0008);

    // 创建相机
    camera = new THREE.PerspectiveCamera(
        75,
        window.innerWidth / window.innerHeight,
        1,
        SPACE_SIZE * 2
    );
    camera.position.z = 800;

    // 创建渲染器
    renderer = new THREE.WebGLRenderer({
        canvas: canvas,
        alpha: true,
        antialias: true
    });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(window.devicePixelRatio);

    // 创建粒子系统
    createParticles();

    // 添加环境光
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);

    // 添加点光源
    const pointLight1 = new THREE.PointLight(0x00f3ff, 2, 500);
    pointLight1.position.set(200, 200, 200);
    scene.add(pointLight1);

    const pointLight2 = new THREE.PointLight(0xff006e, 2, 500);
    pointLight2.position.set(-200, -200, -200);
    scene.add(pointLight2);

    // 监听窗口大小变化
    window.addEventListener('resize', onWindowResize, false);

    // 监听鼠标移动
    document.addEventListener('mousemove', onMouseMove, false);

    // 开始动画循环
    animate();
}

// 初始化手部追踪
async function initHandTracking() {
    videoElement = document.getElementById('video');
    canvasElement = document.getElementById('canvas');
    canvasCtx = canvasElement.getContext('2d');

    // 设置画布大小
    canvasElement.width = 640;
    canvasElement.height = 480;

    try {
        // 使用原生 API 获取摄像头
        const stream = await navigator.mediaDevices.getUserMedia({
            video: {
                width: 640,
                height: 480,
                facingMode: 'user'
            }
        });

        videoElement.srcObject = stream;

        console.log('✅ 摄像头已启动');

        // 等待视频加载
        await new Promise((resolve) => {
            videoElement.onloadedmetadata = () => {
                resolve();
            };
        });

        // 配置 MediaPipe Hands
        hands = new Hands({
            locateFile: (file) => {
                return `https://cdn.jsdelivr.net/npm/@mediapipe/hands/${file}`;
            }
        });

        hands.setOptions({
            maxNumHands: 1,
            modelComplexity: 1,
            minDetectionConfidence: 0.5,
            minTrackingConfidence: 0.5
        });

        hands.onResults(onHandResults);

        console.log('✅ MediaPipe Hands 已配置');

        // 开始处理视频帧
        detectHands();

    } catch (error) {
        console.error('❌ 摄像头启动失败:', error);
        alert('无法访问摄像头，将使用鼠标模式。错误: ' + error.message);
        useHandTracking = false;
    }
}

// 持续检测手部
async function detectHands() {
    if (videoElement && videoElement.readyState === 4) {
        await hands.send({ image: videoElement });
    }
    requestAnimationFrame(detectHands);
}

// 处理手部检测结果
function onHandResults(results) {
    // 清空画布
    canvasCtx.save();
    canvasCtx.clearRect(0, 0, canvasElement.width, canvasElement.height);

    // 绘制视频帧作为背景（镜像）
    canvasCtx.scale(-1, 1);
    canvasCtx.translate(-canvasElement.width, 0);
    canvasCtx.drawImage(videoElement, 0, 0, canvasElement.width, canvasElement.height);
    canvasCtx.setTransform(1, 0, 0, 1, 0, 0);

    if (results.multiHandLandmarks && results.multiHandLandmarks.length > 0) {
        handDetected = true;

        // 获取手部关键点
        const landmarks = results.multiHandLandmarks[0];

        // 使用食指尖端（关键点8）来控制粒子
        const indexFingerTip = landmarks[8];

        // 将手部位置映射到屏幕坐标
        // MediaPipe 返回的是归一化坐标（0-1），需要转换为屏幕坐标
        // 注意：由于视频是镜像的，需要翻转 x 坐标
        const handScreenX = (1 - indexFingerTip.x) * window.innerWidth;
        const handScreenY = indexFingerTip.y * window.innerHeight;

        // 转换为相对于中心的坐标（与鼠标坐标系统一致）
        if (useHandTracking) {
            mouseX = (handScreenX - windowHalfX) * 2;
            mouseY = (handScreenY - windowHalfY) * 2;

            console.log('手部位置:', { x: handScreenX.toFixed(0), y: handScreenY.toFixed(0) });
        }

        // 绘制手部骨架
        if (typeof drawConnectors !== 'undefined' && typeof HAND_CONNECTIONS !== 'undefined') {
            drawConnectors(canvasCtx, landmarks, HAND_CONNECTIONS, {
                color: '#00f3ff',
                lineWidth: 2
            });
            drawLandmarks(canvasCtx, landmarks, {
                color: '#ff006e',
                lineWidth: 1,
                radius: 3
            });
        } else {
            // 手动绘制关键点（备用方案）
            landmarks.forEach((landmark, index) => {
                const x = (1 - landmark.x) * canvasElement.width;
                const y = landmark.y * canvasElement.height;

                canvasCtx.beginPath();
                canvasCtx.arc(x, y, index === 8 ? 8 : 4, 0, 2 * Math.PI);
                canvasCtx.fillStyle = index === 8 ? '#ffd700' : '#ff006e';
                canvasCtx.fill();

                // 添加关键点编号
                if (index === 8) {
                    canvasCtx.fillStyle = '#ffffff';
                    canvasCtx.font = '12px Arial';
                    canvasCtx.fillText('食指', x + 10, y);
                }
            });

            // 绘制连接线（简化版）
            const connections = [
                [0, 1], [1, 2], [2, 3], [3, 4], // 大拇指
                [0, 5], [5, 6], [6, 7], [7, 8], // 食指
                [0, 9], [9, 10], [10, 11], [11, 12], // 中指
                [0, 13], [13, 14], [14, 15], [15, 16], // 无名指
                [0, 17], [17, 18], [18, 19], [19, 20], // 小指
                [5, 9], [9, 13], [13, 17] // 手掌
            ];

            canvasCtx.strokeStyle = '#00f3ff';
            canvasCtx.lineWidth = 2;
            connections.forEach(([start, end]) => {
                const startX = (1 - landmarks[start].x) * canvasElement.width;
                const startY = landmarks[start].y * canvasElement.height;
                const endX = (1 - landmarks[end].x) * canvasElement.width;
                const endY = landmarks[end].y * canvasElement.height;

                canvasCtx.beginPath();
                canvasCtx.moveTo(startX, startY);
                canvasCtx.lineTo(endX, endY);
                canvasCtx.stroke();
            });
        }
    } else {
        handDetected = false;
    }

    canvasCtx.restore();
}

// 创建粒子
function createParticles() {
    const geometry = new THREE.BufferGeometry();
    const positions = new Float32Array(PARTICLE_COUNT * 3);
    const colors = new Float32Array(PARTICLE_COUNT * 3);
    const sizes = new Float32Array(PARTICLE_COUNT);

    const color1 = new THREE.Color(0x00f3ff); // 青色
    const color2 = new THREE.Color(0xff006e); // 品红
    const color3 = new THREE.Color(0xffd700); // 金色

    for (let i = 0; i < PARTICLE_COUNT; i++) {
        const i3 = i * 3;

        // 随机位置
        positions[i3] = (Math.random() - 0.5) * SPACE_SIZE;
        positions[i3 + 1] = (Math.random() - 0.5) * SPACE_SIZE;
        positions[i3 + 2] = (Math.random() - 0.5) * SPACE_SIZE;

        // 随机颜色（在三种颜色之间插值）
        const colorChoice = Math.random();
        let color;
        if (colorChoice < 0.33) {
            color = color1;
        } else if (colorChoice < 0.66) {
            color = color2;
        } else {
            color = color3;
        }

        colors[i3] = color.r;
        colors[i3 + 1] = color.g;
        colors[i3 + 2] = color.b;

        // 随机大小
        sizes[i] = PARTICLE_SIZE * (0.5 + Math.random() * 0.5);
    }

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
    geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));

    // 创建材质
    const material = new THREE.PointsMaterial({
        size: PARTICLE_SIZE,
        vertexColors: true,
        blending: THREE.AdditiveBlending,
        transparent: true,
        opacity: 0.8,
        sizeAttenuation: true,
        map: createParticleTexture(),
        depthWrite: false
    });

    particleSystem = new THREE.Points(geometry, material);
    scene.add(particleSystem);

    particles = particleSystem.geometry.attributes.position.array;
}

// 创建粒子纹理
function createParticleTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 32;
    canvas.height = 32;

    const ctx = canvas.getContext('2d');
    const gradient = ctx.createRadialGradient(16, 16, 0, 16, 16, 16);
    gradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
    gradient.addColorStop(0.4, 'rgba(255, 255, 255, 0.8)');
    gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');

    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 32, 32);

    const texture = new THREE.Texture(canvas);
    texture.needsUpdate = true;
    return texture;
}

// 动画循环
function animate() {
    requestAnimationFrame(animate);

    if (isStarfieldActive) {
        // 更新粒子位置
        updateParticles();

        // 相机跟随鼠标
        camera.position.x += (mouseX - camera.position.x) * 0.05;
        camera.position.y += (-mouseY - camera.position.y) * 0.05;
        camera.lookAt(scene.position);

        // 旋转粒子系统
        particleSystem.rotation.y += 0.0002;
        particleSystem.rotation.x += 0.0001;

        // 渲染场景
        renderer.render(scene, camera);

        // 绘制连接线
        drawConnections();
    }
}

// 更新粒子
function updateParticles() {
    const positions = particleSystem.geometry.attributes.position.array;

    for (let i = 0; i < PARTICLE_COUNT; i++) {
        const i3 = i * 3;

        // 鼠标影响粒子
        const dx = mouseX - positions[i3];
        const dy = mouseY - positions[i3 + 1];
        const distance = Math.sqrt(dx * dx + dy * dy);

        if (distance < 300) {
            const force = (300 - distance) / 300;
            positions[i3] += dx * force * 0.01;
            positions[i3 + 1] += dy * force * 0.01;
        }

        // 边界检测
        if (Math.abs(positions[i3]) > SPACE_SIZE / 2) {
            positions[i3] = -positions[i3];
        }
        if (Math.abs(positions[i3 + 1]) > SPACE_SIZE / 2) {
            positions[i3 + 1] = -positions[i3 + 1];
        }
        if (Math.abs(positions[i3 + 2]) > SPACE_SIZE / 2) {
            positions[i3 + 2] = -positions[i3 + 2];
        }
    }

    particleSystem.geometry.attributes.position.needsUpdate = true;
}

// 绘制粒子连接线
function drawConnections() {
    // 移除旧的连接线
    const oldLines = scene.children.filter(child => child.type === 'LineSegments');
    oldLines.forEach(line => scene.remove(line));

    const positions = particleSystem.geometry.attributes.position.array;
    const linePositions = [];

    // 只检查部分粒子以提高性能
    const checkCount = Math.min(500, PARTICLE_COUNT);

    for (let i = 0; i < checkCount; i++) {
        const i3 = i * 3;

        for (let j = i + 1; j < checkCount; j++) {
            const j3 = j * 3;

            const dx = positions[i3] - positions[j3];
            const dy = positions[i3 + 1] - positions[j3 + 1];
            const dz = positions[i3 + 2] - positions[j3 + 2];
            const distance = Math.sqrt(dx * dx + dy * dy + dz * dz);

            if (distance < CONNECTION_DISTANCE) {
                linePositions.push(
                    positions[i3], positions[i3 + 1], positions[i3 + 2],
                    positions[j3], positions[j3 + 1], positions[j3 + 2]
                );
            }
        }
    }

    if (linePositions.length > 0) {
        const lineGeometry = new THREE.BufferGeometry();
        lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute(linePositions, 3));

        const lineMaterial = new THREE.LineBasicMaterial({
            color: 0x00f3ff,
            transparent: true,
            opacity: 0.15,
            blending: THREE.AdditiveBlending
        });

        const lineSegments = new THREE.LineSegments(lineGeometry, lineMaterial);
        scene.add(lineSegments);
    }
}

// 窗口大小调整
function onWindowResize() {
    windowHalfX = window.innerWidth / 2;
    windowHalfY = window.innerHeight / 2;

    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize(window.innerWidth, window.innerHeight);
}

// 鼠标移动
function onMouseMove(event) {
    mouseX = (event.clientX - windowHalfX) * 2;
    mouseY = (event.clientY - windowHalfY) * 2;

    // 更新自定义光标位置
    document.body.style.setProperty('--mouse-x', event.clientX + 'px');
    document.body.style.setProperty('--mouse-y', event.clientY + 'px');
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    // 初始化星空场景
    initStarfield();

    // 初始化手部追踪
    initHandTracking();

    // 激活自定义光标
    document.body.classList.add('cursor-active');

    // 创建手部状态指示器
    const handStatus = document.createElement('div');
    handStatus.className = 'hand-status';
    handStatus.textContent = '等待检测手部...';
    document.body.appendChild(handStatus);

    // 实时更新手部状态
    setInterval(() => {
        if (isStarfieldActive) {
            if (handDetected) {
                handStatus.textContent = '✓ 手部已识别';
                handStatus.classList.add('detected');
            } else {
                handStatus.textContent = '请将手移入镜头';
                handStatus.classList.remove('detected');
            }
        }
    }, 100);

    // 实时更新坐标
    setInterval(() => {
        const lat = (Math.random() * 180 - 90).toFixed(1);
        const lon = (Math.random() * 360 - 180).toFixed(1);
        document.getElementById('coordinates').textContent =
            `${Math.abs(lat)}°${lat >= 0 ? 'N' : 'S'} ${Math.abs(lon)}°${lon >= 0 ? 'E' : 'W'}`;
    }, 3000);

    // 启动按钮点击事件
    const enterBtn = document.getElementById('enterBtn');
    const homepage = document.getElementById('homepage');
    const starfieldCanvas = document.getElementById('starfield');
    const transition = document.getElementById('transition');

    enterBtn.addEventListener('click', function() {
        // 激活过渡动画
        transition.classList.add('active');

        // 播放过渡音效（如果需要）
        // playSound('transition');

        // 延迟隐藏主页
        setTimeout(() => {
            homepage.classList.add('hidden');
            starfieldCanvas.classList.add('visible');
            isStarfieldActive = true;

            // 显示画布和手部状态
            canvasElement.classList.add('active');
            handStatus.classList.add('active');

            console.log('✅ 星空场景已激活，手部追踪模式:', useHandTracking);
        }, 800);

        // 移除过渡遮罩
        setTimeout(() => {
            transition.classList.remove('active');
        }, 2000);
    });

    // 鼠标悬停效果
    enterBtn.addEventListener('mouseenter', function() {
        this.style.transform = 'scale(1.05)';
    });

    enterBtn.addEventListener('mouseleave', function() {
        this.style.transform = 'scale(1)';
    });
});

// 更新自定义光标位置
document.addEventListener('mousemove', (e) => {
    const cursor = document.querySelector('body::before');
    document.documentElement.style.setProperty('--cursor-x', e.clientX + 'px');
    document.documentElement.style.setProperty('--cursor-y', e.clientY + 'px');
});

// 添加自定义光标样式更新
const style = document.createElement('style');
style.textContent = `
    body::before {
        left: var(--cursor-x, -100px);
        top: var(--cursor-y, -100px);
        transform: translate(-50%, -50%);
    }
`;
document.head.appendChild(style);

// 按键切换手部追踪/鼠标模式（按 H 键切换）
document.addEventListener('keydown', (e) => {
    if (e.key === 'h' || e.key === 'H') {
        useHandTracking = !useHandTracking;
        const handStatus = document.querySelector('.hand-status');
        if (handStatus) {
            if (useHandTracking) {
                handStatus.textContent = '模式: 手部追踪';
                if (canvasElement) canvasElement.style.opacity = '1';
                console.log('切换到手部追踪模式');
            } else {
                handStatus.textContent = '模式: 鼠标控制';
                if (canvasElement) canvasElement.style.opacity = '0.3';
                console.log('切换到鼠标模式');
            }
        }
    }
});
