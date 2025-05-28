import { INodeType, INodeTypeDescription, IExecuteFunctions, NodeConnectionType } from 'n8n-workflow';
import ytsr from '@distube/ytsr';
import { YoutubeTranscript } from 'youtube-transcript';

export class YouTubeSearch implements INodeType {
	description: INodeTypeDescription = {
		displayName: 'YouTube Search',
		name: 'youTubeSearch',
		group: ['transform'],
		version: 1,
		description: 'Search YouTube videos using ytsr',
		defaults: {
			name: 'YouTube Search',
		},
		usableAsTool: true,
		inputs: [NodeConnectionType.Main],
		outputs: [NodeConnectionType.Main],
		properties: [
			{
				displayName: 'Search Query',
				name: 'query',
				type: 'string',
				default: '',
				placeholder: 'Search term...',
				required: true,
				description: 'Text to search on YouTube',
			},
		],
	};

	async execute(this: IExecuteFunctions) {
		const items = this.getInputData();
		const returnData = [];

		for (let i = 0; i < items.length; i++) {
			const query = this.getNodeParameter('query', i) as string;

			try {
				const results = await ytsr(query, { limit: 5 });

				let videos: any[] = results.items.filter((item: any) => item.type === 'video');

				// Fetch transcript for each video
				for (const video of videos) {
					try {
						const transcriptResult = await YoutubeTranscript.fetchTranscript(video.url);
						const transcript = transcriptResult.map((r: any) => r.text).join(' ');
						// Add the transcript to the video object
						videos = videos.map((v) => (v.id === video.id ? { ...v, transcript } : v));
					} catch (error) {
						// If transcript fetch fails, continue without transcript
						// Silently continue - transcript is optional
					}
				}

				returnData.push({ json: { videos } });
			} catch (error) {
				throw new Error(`YouTube search failed: ${error.message}`);
			}
		}

		return this.prepareOutputData(returnData);
	}
}
