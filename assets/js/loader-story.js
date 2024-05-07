const useStory = async (storyURL) => {
  const resp = await fetch(storyURL);
  const respdata = await resp.json();
  return respdata;
};
