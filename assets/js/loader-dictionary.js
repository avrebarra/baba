const DICTIONARY_STORAGE_KEY = "dictionary_data";
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes in milliseconds

const useDictionary = async () => {
  const cachedData = localStorage.getItem(DICTIONARY_STORAGE_KEY);
  const cacheTimestamp = localStorage.getItem(DICTIONARY_STORAGE_KEY + "_timestamp");

  if (cachedData && cacheTimestamp && parseInt(cacheTimestamp, 10) + CACHE_DURATION > Date.now()) {
    return JSON.parse(cachedData);
  }

  // Fetch data if cache is missing or stale
  const resp = await fetch(DICTIONARY_URL);
  const respdata = await resp.json();

  // Update local storage with fetched data
  localStorage.setItem(DICTIONARY_STORAGE_KEY, JSON.stringify(respdata));
  localStorage.setItem(DICTIONARY_STORAGE_KEY + "_timestamp", Date.now().toString());

  // Invalidate cache after 5 minutes
  setTimeout(() => {
    localStorage.removeItem(DICTIONARY_STORAGE_KEY);
    localStorage.removeItem(DICTIONARY_STORAGE_KEY + "_timestamp");
  }, CACHE_DURATION);

  return respdata;
};
