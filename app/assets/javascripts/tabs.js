document.addEventListener('DOMContentLoaded', function() {
  const tabList = document.querySelector('[role="tablist"]');
  if (!tabList) return;

  const tabs = Array.from(tabList.querySelectorAll('[role="tab"]'));

  function selectHandler(tab){
    // Update tabindex and aria-selected for all tabs
    tabs.forEach(t => {
      t.setAttribute('tabindex', '-1');
      t.setAttribute('aria-selected', 'false');
      t.classList.remove('active-section');
    });

    // Update the clicked tab
    tab.setAttribute('tabindex', '0');
    tab.setAttribute('aria-selected', 'true');
    tab.classList.add('active-section');
  };

  // Add keyboard event listener to the tablist
  tabList.addEventListener('keydown', function(e) {
    const target = e.target;
    const key = e.key;
    const link = target.querySelector('a');

    if (!target.matches('[role="tab"]')) return;

    let index = tabs.indexOf(target);
    let newIndex;

    // Handle different key presses
    switch (key) {
      case 'ArrowLeft':
        newIndex = index - 1;
        if (newIndex < 0) newIndex = tabs.length - 1;
        break;
      case 'ArrowRight':
        newIndex = index + 1;
        if (newIndex >= tabs.length) newIndex = 0;
        break;
      case 'Home':
        newIndex = 0;
        break;
      case 'End':
        newIndex = tabs.length - 1;
        break;
      case 'Enter':
      case ' ':
        e.preventDefault();

        selectHandler(target);
        if (link) {
          link.click();
        }
        return;
      default:
        return;
    }

    e.preventDefault();
    // Update tab focus
    tabs[newIndex].focus();
  });

  // Add click handlers
  tabs.forEach(tab => {
    // Handle click on the tab
    tab.addEventListener('click', (e) => {
      selectHandler(tab);
    });
  });
});
