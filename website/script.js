// DOM加载完成后执行
(document.addEventListener('DOMContentLoaded', function() {
    // FAQ折叠功能
    const faqQuestions = document.querySelectorAll('.faq-question');
    
    faqQuestions.forEach(question => {
        question.addEventListener('click', function() {
            const faqItem = this.parentElement;
            const isActive = faqItem.classList.contains('active');
            
            // 关闭所有FAQ项
            document.querySelectorAll('.faq-item').forEach(item => {
                item.classList.remove('active');
            });
            
            // 如果当前项未激活，则激活它
            if (!isActive) {
                faqItem.classList.add('active');
            }
        });
    });
    
    // 平滑滚动
    const smoothScrollLinks = document.querySelectorAll('a[href^="#"]');
    
    smoothScrollLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                const navbarHeight = document.querySelector('.navbar').offsetHeight;
                const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - navbarHeight;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
    
    // 导航栏滚动效果
    const navbar = document.querySelector('.navbar');
    
    window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
            navbar.style.backgroundColor = 'rgba(255, 255, 255, 0.98)';
            navbar.style.boxShadow = '0 1px 3px rgba(0, 0, 0, 0.1)';
        } else {
            navbar.style.backgroundColor = 'rgba(255, 255, 255, 0.95)';
            navbar.style.boxShadow = 'none';
        }
    });
    
    // 按钮悬停效果
    const buttons = document.querySelectorAll('.btn-primary, .btn-secondary, .btn-download');
    
    buttons.forEach(button => {
        button.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-2px)';
        });
        
        button.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });
    
    // 卡片悬停效果
    const cards = document.querySelectorAll('.feature-card, .tech-card');
    
    cards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-4px)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });
    
    // 应用预览悬停效果
    const appPreview = document.querySelector('.app-preview');
    if (appPreview) {
        appPreview.addEventListener('mouseenter', function() {
            this.style.transform = 'rotate(0)';
        });
        
        appPreview.addEventListener('mouseleave', function() {
            this.style.transform = 'rotate(-2deg)';
        });
    }
    
    // 设计展示悬停效果
    const designShowcase = document.querySelector('.design-showcase');
    if (designShowcase) {
        designShowcase.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.02)';
        });
        
        designShowcase.addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1)';
        });
    }
    
    // 社交链接悬停效果
    const socialLinks = document.querySelectorAll('.social-link');
    
    socialLinks.forEach(link => {
        link.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-2px)';
        });
        
        link.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });
    
    // 表单提交处理
    const contactForm = document.querySelector('form');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // 获取表单数据
            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const message = document.getElementById('message').value;
            
            // 简单验证
            if (!name || !email || !message) {
                alert('请填写所有必填字段');
                return;
            }
            
            // 模拟表单提交
            alert('留言已发送，我们会尽快回复您！');
            contactForm.reset();
        });
    }
    
    // 页面加载动画
    const fadeInElements = document.querySelectorAll('.section-header, .feature-card, .tech-card, .faq-item, .contact-item');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.1
    });
    
    fadeInElements.forEach(element => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(20px)';
        element.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
        observer.observe(element);
    });
    
    // 导航栏链接高亮
    const sections = document.querySelectorAll('section');
    const navbarLinks = document.querySelectorAll('.navbar-link');
    
    window.addEventListener('scroll', function() {
        let current = '';
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            if (window.scrollY >= sectionTop - 100) {
                current = section.getAttribute('id');
            }
        });
        
        navbarLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${current}`) {
                link.classList.add('active');
            }
        });
    });
    
    // 导航栏链接激活状态样式
    const style = document.createElement('style');
    style.textContent = `
        .navbar-link.active {
            color: var(--primary-color);
        }
        
        .navbar-link.active::after {
            width: 100%;
        }
    `;
    document.head.appendChild(style);
    
    // 图片加载错误处理
    const images = document.querySelectorAll('img');
    
    images.forEach(image => {
        image.addEventListener('error', function() {
            this.src = 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Gentle%20Companion%20placeholder%20image%20with%20purple%20gradient%20background&image_size=square';
            this.alt = 'Gentle Companion 图片';
        });
    });
}));
