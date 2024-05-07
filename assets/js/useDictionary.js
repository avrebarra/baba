const useDictionary = async (lang) => {
  const key = "babba:dictionary:" + lang;
  const expiry = 5 * 60 * 1000; // 5 minutes in milliseconds

  const cachedData = localStorage.getItem(key);
  const cacheTimestamp = localStorage.getItem(key + "_timestamp");
  if (cachedData && cacheTimestamp && parseInt(cacheTimestamp, 10) + expiry > Date.now()) {
    return JSON.parse(cachedData);
  }

  // fetch data if cache is missing or stale
  const requesturl = Babba.baseURL + `/assets/data/${lang}.dict.json`;
  const resp = await fetch(requesturl);
  const respdata = await resp.json();

  // update local storage with fetched data
  localStorage.setItem(key, JSON.stringify(respdata));
  localStorage.setItem(key + "_timestamp", Date.now().toString());

  // invalidate cache after 5 minutes
  setTimeout(() => {
    localStorage.removeItem(key);
    localStorage.removeItem(key + "_timestamp");
  }, expiry);

  return respdata;
};
