const useStoryAssets = async (storyID, options = { forceRefresh: false }) => {
  const expiryInMinutes = 15;
  const key = `babba.story.${storyID}`;

  if (!options.forceRefresh) {
    const cachedData = localStorage.getItem(key);

    if (cachedData) {
      const parsedData = JSON.parse(cachedData);
      const cacheExpiry = parsedData.cacheExpiry;

      if (Date.now() < cacheExpiry) {
        return parsedData.data;
      }
    }
  }

  const requesturl = Babba.baseURL + storyID + ".json";
  const resp = await fetch(requesturl);
  const respdata = await resp.json();

  const cacheData = {
    data: respdata,
    cacheExpiry: Date.now() + expiryInMinutes * 60 * 1000,
  };

  localStorage.setItem(key, JSON.stringify(cacheData));
  return respdata;
};
